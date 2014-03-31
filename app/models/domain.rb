require 'scoped_finders'

# = Domain
#
# A #Domain is a unique domain name entry, and contains various #Record entries to
# represent its data.
#
# The zone is used for the following purposes:
# * It is the $ORIGIN off all its records
# * It specifies a default $TTL
#
class Domain < ActiveRecord::Base
  audited :allow_mass_assignment => true
  has_associated_audits

  belongs_to :user

  has_many :records, :dependent => :destroy

  has_one  :soa_record,    :class_name => 'SOA'
  has_many :ns_records,    :class_name => 'NS'
  has_many :mx_records,    :class_name => 'MX'
  has_many :a_records,     :class_name => 'A'
  has_many :txt_records,   :class_name => 'TXT'
  has_many :cname_records, :class_name => 'CNAME'
  has_one  :loc_record,    :class_name => 'LOC'
  has_many :aaaa_records,  :class_name => 'AAAA'
  has_many :spf_records,   :class_name => 'SPF'
  has_many :srv_records,   :class_name => 'SRV'
  has_many :sshfp_records, :class_name => 'SSHFP'
  has_many :ptr_records,   :class_name => 'PTR'

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :type, :in => %w(NATIVE MASTER SLAVE), :message => "must be one of NATIVE, MASTER, or SLAVE"

  validates_presence_of :master, :if => :slave?
  validates_format_of :master, :if => :slave?,
    :allow_blank => true,
    :with => /\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z/

  # Disable single table inheritence (STI)
  self.inheritance_column = 'not_used_here'

  after_create :create_soa_record

  # Virtual attributes that ease new zone creation. If present, they'll be
  # used to create an SOA for the domain
  SOA_FIELDS = [ :primary_ns, :contact, :refresh, :retry, :expire, :minimum ]
  SOA_FIELDS.each do |f|
    attr_accessor f
    validates_presence_of f, :on => :create, :unless => :slave?
  end

  # Serial is optional, but will be passed to the SOA too
  attr_accessor :serial

  # Helper attributes for API clients and forms (keep it RESTful)
  attr_accessor :zone_template_id, :zone_template_name

  # Needed for acts_as_audited (TODO: figure out why this is needed...)
  #attr_accessible :type

  # Scopes
  scope :user, lambda { |user| user.admin? ? nil : where(:user_id => user.id) }
  default_scope order('name')

  class << self

    def search( string, page, user = nil )
      query = self.scoped
      query = query.user( user ) unless user.nil?
      query.where('name LIKE ?', "%#{string}%").paginate( :page => page )
    end

  end

  # arguably should have as_json includes here too FIX
  def to_xml(options={})
    super(options.merge(:include => :records))
  end
  
  # Are we a slave domain
  def slave?
    self.type == 'SLAVE'
  end

  # return the records, excluding the SOA record
  def records_without_soa
    records.includes(:domain).all.select { |r| !r.is_a?( SOA ) }.sort_by {|r| [r.shortname, r.type]}
  end

  # Expand our validations to include SOA details
  def after_validation_on_create #:nodoc:
    soa = SOA.new( :domain => self )
    SOA_FIELDS.each do |f|
      soa.send( "#{f}=", send( f ) )
    end
    soa.serial = serial unless serial.nil? # Optional

    unless soa.valid?
      soa.errors.each_full do |e|
        errors.add_to_base e
      end
    end
  end

  # Setup an SOA if we have the requirements
  def create_soa_record #:nodoc:
    return if self.slave?

    soa = SOA.new( :domain => self )
    SOA_FIELDS.each do |f|
      soa.send( "#{f}=", send( f ) )
    end
    soa.serial = serial unless serial.nil? # Optional
    soa.minimum = [10800, soa.minimum].min
    soa.save
  end

  def attach_errors(e)
    e.message.split(":")[1].split(",").uniq.each do |m|
      self.errors.add(m , '')
    end
  end
end
