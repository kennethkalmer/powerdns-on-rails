class ZoneTemplate < ActiveRecord::Base
  
  has_many :record_templates
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :ttl
  
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
  
  # Build a new zone using +self+ as a template. +zone+ should be valid zone
  # name. This method will throw exceptions as it encounters errors, and will
  # use a transaction to complete the operation
  def build( zone_name )
    zone = Zone.new( :name => zone_name, :ttl => self.ttl )
    
    self.class.transaction do
      # Pick our SOA template out, and populate the zone
      soa_template = record_templates.detect { |r| r.record_type == 'SOA' }
      built_soa_template = soa_template.build( zone_name )
      Zone::SOA_FIELDS.each do |f|
        zone.send( "#{f}=", built_soa_template.send( f ) )
      end
      
      # save the zone or die
      zone.save!
      
      # get the templates
      templates = record_templates.dup
      
      # now build the remaining records according to the templates
      templates.delete( soa_template )
      templates.each do |template|
        record = template.build( zone_name )
        record.zone = zone
        record.save!
      end
    end
    
    zone
  end
  
  # If the template has an SOA record, it can be used for building zones
  def has_soa?
    record_templates.count( :conditions => "record_type LIKE 'SOA'" ) == 1
  end
  
end
