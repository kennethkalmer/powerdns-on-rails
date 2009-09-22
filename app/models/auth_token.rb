# Authentication tokens are used to give someone temporary access to a single
# domain for editing. An authentication token controls the permissions the token
# holder has.
#
# A token has a default permission, either allow or deny, and then specifies
# additional restrictions/relaxations towards specific RR's in the domain.
#
# TODO: Document this
#
class AuthToken < ActiveRecord::Base

  belongs_to :domain
  belongs_to :user

  validates_presence_of :domain_id, :user_id, :token, :expires_at, :permissions

  serialize :permissions

  class << self

    # Generate a random 16 character token
    def token
      chars = ("a".."z").to_a + ("1".."9").to_a
      Array.new( 16, '' ).collect{ chars[ rand(chars.size) ] }.join
    end

    def authenticate( token )
      t = find_by_token( token )

      unless t.nil? || t.expires_at < Time.now
        return t
      end
    end
  end

  def after_initialize #:nodoc:
    # Ensure uniqueness
    t = self.class.token
    while self.class.count( :conditions => ['token = ?', t] ) > 1
      t = self.class.token
    end

    self.token = t

    # Default policies
    self.permissions = {
      'policy' => 'deny',
      'new' => false,
      'remove' => false,
      'allowed' => [],
      'protected' => [],
      'protected_types' => []
    } if self.permissions.blank?
  end

  # Set the default policy of the token
  def policy=( val )
    val = val.to_s
    raise "Invalid policy" unless val == "allow" || val == "deny"

    self.permissions['policy'] = val
  end

  # Return the default policy
  def policy
    self.permissions['policy'].to_sym
  end

  # Are new RR's allowed (defaults to +false+)
  def allow_new_records?
    self.permissions['new']
  end

  def allow_new_records=( bool )
    self.permissions['new'] = bool
  end

  # Can RR's be removed (defaults to +false+)
  def remove_records?
    self.permissions['remove']
  end

  def remove_records=( bool )
    self.permissions['remove'] = bool
  end

  # Allow the change of the specific RR. Can take an instance of #Record or just
  # the name of the RR (with/without the domain name)
  def can_change( record, type = '*' )
    name, type = get_name_and_type_from_param( record, type )
    self.permissions['allowed'] << [ name, type ]
  end

  # Protect the RR from change. Can take an instance of #Record or just the name
  # of the RR (with/without the domain name)
  def protect( record, type = '*' )
    name, type = get_name_and_type_from_param( record, type )
    self.permissions['protected'] << [ name, type ]
  end

  # Protect all RR's of the provided type
  def protect_type( type )
    self.permissions['protected_types'] << type.to_s
  end

  # Walk the permission tree to see if the record can be changed. Can take an
  # instance of #Record, or just the name of the RR (with/without the domain
  # name)
  def can_change?( record, type = '*' )
    name, type = get_name_and_type_from_param( record, type )

    # NS records?
    return false if type == 'NS' || type == 'SOA'

    # Type protected?
    return false if self.permissions['protected_types'].include?( type )

    # RR protected?
    return false if self.permissions['protected'].detect do |r|
      r[0] == name && (r[1] == type || r[1] == '*' || type == '*')
    end

    # Allowed?
    return true if self.permissions['allowed'].detect do |r|
      r[0] == name && (r[1] == type || r[1] == '*' || type == '*')
    end

    # Default policy
    return self.permissions['policy'] == 'allow'
  end

  # Walk the permission tree to see if the record can be removed. Can take an
  # instance of #Record, or just the name of the RR (with/without the domain
  # name)
  def can_remove?( record, type = '*' )
    return false unless can_change?( record, type )

    return false if !remove_records?

    true
  end

  # Can this record be added?
  def can_add?( record, type = '*' )
    return false unless can_change?( record, type )

    return false if !allow_new_records?

    true
  end

  # If the user can add new records, this will return a string array of the new
  # RR types the user can add
  def new_types
    return [] unless allow_new_records?

    # build our list
    Record.record_types - %w{ SOA NS } - self.permissions['protected_types']
  end

  # Force the token to expire
  def expire
    update_attribute :expires_at, 1.minute.ago
  end

  def expired?
    self.expires_at <= Time.now
  end

  # A token can only have the token role...
  def has_role?( role_in_question )
    role_in_question == 'token'
  end

  private

  def get_name_and_type_from_param( record, type = nil )
    name, type =
      case record
      when Record
        [ record.name, record.class.to_s ]
      else
        type = type.nil? ? '*' : type
        [ record, type ]
      end

    name += '.' + self.domain.name unless self.domain.nil? || name =~ /#{self.domain.name}$/
    name.gsub!(/^\./,'') # Strip leading dots off

    return name, type
  end

  def validate #:nodoc:
    ensure_future_expiry!
  end

  def ensure_future_expiry! #:nodoc:
    if self.expires_at && self.expires_at <= Time.now
      errors.add(:expires_at, I18n.t(:message_domain_expiry_error))
    end
  end
end
