class ZoneTemplate < ActiveRecord::Base
  
  has_many :record_templates
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # Build a new zone using +self+ as a template. +zone+ should be valid zone 
  # name. This method will throw exceptions as it encounters errors, and will
  # use a transaction to complete the operation
  def build( zone_name )
    zone = Zone.new( :name => zone_name, :ttl => self.ttl )
    
    self.class.transaction do
      # Pick our SOA template out, and populate the zone
      soa_template = record_templates.detect { |r| r.record_type == 'SOA' }
      zone.primary_ns = soa_template.primary_ns
      zone.contact = soa_template.contact
      zone.refresh = soa_template.refresh
      zone.retry = soa_template.retry
      zone.expire = soa_template.expire
      zone.minimum = soa_template.minimum
      
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
end
