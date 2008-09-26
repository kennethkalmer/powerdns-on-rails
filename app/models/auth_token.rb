# Authentication tokens are used to give someone temporary access to a single
# domain for editing. An authentication token controls the permissions the token
# holder has.
# 
# A token has a default permission, either allow or deny, and then specifies
# additional restrictions/relaxations towards specific RR's in the domain.
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
    
  end
  
  def after_initialize #:nodoc:
    # Ensure uniqueness
    t = self.class.token
    while self.class.count( :conditions => ['token = ?', t] ) > 1
      t = self.class.token
    end
    
    self.token = t
    
    # Default policies
    @permissions = { 
      'policy' => 'deny', 
      'new' => false, 
      'remove' => false,
      'allowed' => [],
      'protected' => [],
      'protected_types' => []
    }
  end
  
  # Set the default policy of the token
  def policy=( val )
    raise "Invalid policy" unless val == :allow || val == :deny
    
    @permissions['policy'] = val.to_s
  end
  
  # Return the default policy
  def policy
    @permissions['policy'].to_sym
  end
  
  # Are new RR's allowed (defaults to +false+)
  def allow_new_records?
    @permissions['new']
  end
  
  def allow_new_records=( bool )
    @permissions['new'] = bool
  end
  
  # Can RR's be removed (defaults to +false+)
  def remove_records?
    @permissions['remove']
  end
  
  def remove_records=( bool )
    @permissions['remove'] = bool
  end
  
  # Allow the change of the specific RR. Can take an instance of #Record or just
  # the name of the RR (with/without the domain name)
  def can_change( record )
    name = get_name_from_param( record )
    @permissions['allowed'] << name
  end
  
  # Protect the RR from change. Can take an instance of #Record or just the name
  # of the RR (with/without the domain name)
  def protect( record )
    name = get_name_from_param( record )
    @permissions['protected'] << name
  end
  
  # Protect all RR's of the provided type
  def protect_type( type )
    @permissions['protected_types'] << type.to_s
  end
  
  # Walk the permission tree to see if the record can be changed. Can take an
  # instance of #Record, or just the name of the RR (with/without the domain
  # name)
  def can_change?( record )
    name = get_name_from_param( record )
    
    type = case record
    when Record
      record.class.to_s
    else
      type = self.domain.records.find(
        :first, :conditions => ['name = ?', name]
      ).class.to_s
    end
    
    # NS records?
    return false if type == 'NS' || type == 'SOA'
    
    # Type protected?
    return false if @permissions['protected_types'].include?( type )
    
    # RR protected?
    return false if @permissions['protected'].include?( name )
    
    # Allowed?
    return true if @permissions['allowed'].include?( name )
    
    # Default policy
    return @permissions['policy'] == 'allow'
  end
  
  private
  
  def get_name_from_param( record )
    name = record.is_a?( Record ) ? record.name : record
    name += '.' + self.domain.name unless self.domain.nil? || name =~ /#{self.domain.name}$/
    name
  end
  
  def validate #:nodoc:
    ensure_future_expiry!
  end
  
  def ensure_future_expiry! #:nodoc:
    if self.expires_at && self.expires_at <= Time.now
      errors.add(:expires_at, 'should be in the future') 
    end
  end
end
