class RecordTemplate < ActiveRecord::Base
  
  belongs_to :zone_template
  
  # General validations
  validates_presence_of :zone_template_id
  validates_associated :zone_template
  validates_presence_of :record_type
  
  # Convert this template record into a instance +record_type+ with the 
  # attributes of the template copied over to the instance
  def build
    # get the class of the record_type
    record_class = self.record_type.constantize

    # duplicate our own attributes, strip out the ones the destination doesn't
    # have (and the id as well)
    attrs = self.attributes.dup
    attrs.delete_if { |k,_| !record_class.columns.map( &:name ).include?( k ) }
    attrs.delete( :id )

    # instantiate a new destination with our duplicated attributes & validate
    record_class.new( attrs )
  end
  
  # Here we perform some magic to inherit the validations from the "destination"
  # model without any duplication of rules. This allows us to simply extend the
  # appropriate record and gain those validations in the templates
  def validate #:nodoc:
    unless self.record_type.nil?
      record = build
      record.errors.each do |k,v|
        next if k == "zone_id" # skip associations we don't have

        self.errors.add( k, v )
      end unless record.valid?
    end
  end
  
end
