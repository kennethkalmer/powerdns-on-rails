class ZoneTemplate < ActiveRecord::Base

  belongs_to :user
  has_many :record_templates

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :ttl
  validates_inclusion_of :type, :in => %w(NATIVE MASTER SLAVE), :message => "must be one of NATIVE, MASTER"
  validates_presence_of :master, :if => :slave?
  validates_format_of :master, :if => :slave?,
    :allow_blank => true,
    :with => /\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z/
  # Disable single table inheritence (STI)
  self.inheritance_column = 'not_used_here'
  # Scopes
  scope :user, lambda { |user| user.admin? ? nil : where(:user_id => user.id) }
  scope :with_soa, joins(:record_templates).where('record_templates.record_type = ?', 'SOA')
  default_scope order('name')

  class << self

    # Custom find that takes one additional parameter, :require_soa (bool), for
    # restricting the returned resultset to only instances that #has_soa?
    def find_with_validations( *args )
      options = args.extract_options!
      valid_soa = options.delete( :require_soa ) || false

      # find as per usual
      records = find_without_validations( *args << options )

      if valid_soa
        records.delete_if { |z| !z.has_soa? }
      end

      records # give back
    end
    alias_method_chain :find, :validations
  end

  # Build a new zone using +self+ as a template. +domain+ should be valid domain
  # name. Pass the optional +user+ object along to have the new one owned by the
  # user, otherwise it's for admins only.
  #
  # This method will throw exceptions as it encounters errors, and will use a
  # transaction to complete/rollback the operation.
  def build( domain_name, user = nil )
    domain = Domain.new( :name => domain_name, :ttl => self.ttl, :type => self.type )
    domain.master = self.master if slave?
    domain.user = user if user.is_a?( User )

    self.class.transaction do
      # Pick our SOA template out, and populate the zone
      soa_template = record_templates.detect { |r| r.record_type == 'SOA' }
      built_soa_template = soa_template.build( domain_name )
      Domain::SOA_FIELDS.each do |f|
        domain.send( "#{f}=", built_soa_template.send( f ) )
      end

      # save the zone or die
      domain.save!

      # get the templates
      templates = record_templates.dup

      Record.batch do
        # now build the remaining records according to the templates
        templates.delete( soa_template )
        templates.each do |template|
          record = template.build( domain_name )
          record.domain = domain
          record.save!
        end
      end
    end

    domain
  end

  # If the template has an SOA record, it can be used for building zones
  def has_soa?
    record_templates.count( :conditions => "record_type LIKE 'SOA'" ) == 1
  end
  # Are we a slave domain template
  def slave?
    self.type == 'SLAVE'
  end
end
