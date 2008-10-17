class RecordTemplate < ActiveRecord::Base
  
  belongs_to :zone_template
  
  # General validations
  validates_presence_of :zone_template_id
  validates_associated :zone_template
  validates_presence_of :record_type
  
  before_save :update_soa_content
  
  # We need to cope with the SOA convenience
  SOA::SOA_FIELDS.each do |f|
    attr_accessor f
  end
  
  class << self
    def record_types
      Record.record_types
    end
  end
  
  # Convert our +content+ field into convenience variables
  def after_initialize 
    update_convenience_accessors
  end
  
  # Hook into #reload
  def reload_with_content
    reload_without_content
    update_convenience_accessors
  end
  alias_method_chain :reload, :content
  
  # Convert this template record into a instance +record_type+ with the 
  # attributes of the template copied over to the instance
  def build( domain_name = nil )
    # get the class of the record_type
    record_class = self.record_type.constantize

    # duplicate our own attributes, strip out the ones the destination doesn't
    # have (and the id as well)
    attrs = self.attributes.dup
    attrs.delete_if { |k,_| !record_class.columns.map( &:name ).include?( k ) }
    attrs.delete( :id )
    
    # parse each attribute, looking for %ZONE%
    unless domain_name.nil?
      attrs.keys.each do |k|
        attrs[k] = attrs[k].gsub( '%ZONE%', domain_name ) if attrs[k].is_a?( String )
      end
    end
    
    # Handle SOA convenience fields if needed
    if soa?
      SOA::SOA_FIELDS.each do |soa_field|
        attrs[soa_field] = instance_variable_get("@#{soa_field}")
      end
    end

    # instantiate a new destination with our duplicated attributes & validate
    record_class.new( attrs )
  end
  
  def soa?
    self.record_type == 'SOA'
  end
  
  def content
    soa? ? SOA::SOA_FIELDS.map{ |f| instance_variable_get("@#{f}") || 0 }.join(' ') : self[:content]
  end
  
  # Manage TTL inheritance here
  def before_validation #:nodoc:
    unless self.zone_template_id.nil?
      self.ttl = self.zone_template.ttl if self.ttl.nil?
    end
  end
  
  # Manage SOA content
  def update_soa_content #:nodoc:
    self[:content] = content
  end
  
  # Here we perform some magic to inherit the validations from the "destination"
  # model without any duplication of rules. This allows us to simply extend the
  # appropriate record and gain those validations in the templates
  def validate #:nodoc:
    unless self.record_type.blank?
      record = build
      record.errors.each do |k,v|
        # skip associations we don't have, validations we don't care about
        next if k == "domain_id" || k == "name" 

        self.errors.add( k, v )
      end unless record.valid?
    end
  end
  
  private
  
  # Update our convenience accessors when the object has changed
  def update_convenience_accessors
    return unless self.record_type == 'SOA'
    
    # Setup our convenience values
    @primary_ns, @contact, @serial, @refresh, @retry, @expire, @minimum = 
      self[:content].split(/\s+/) unless self[:content].blank?
    %w{ serial refresh retry expire minimum }.each do |i|
      value = instance_variable_get("@#{i}")
      value = value.to_i unless value.nil?
      send("#{i}=", value )
    end
  end
end
