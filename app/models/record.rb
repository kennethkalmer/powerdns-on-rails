class Record < ActiveRecord::Base
  
  belongs_to :zone

  validates_presence_of :zone_id
  validates_associated :zone
  validates_numericality_of( 
    :ttl, 
    :greater_than_or_equal_to => 0, 
    :only_integer => true 
  )
  
  class_inheritable_accessor :batch_soa_updates
  
  class << self
    
    # Restrict the SOA serial number updates to just one during the execution
    # of the block. Useful for batch updates to a zone
    def batch
      raise ArgumentError, "Block expected" unless block_given?
      
      self.batch_soa_updates = []
      yield
      self.batch_soa_updates = nil
    end
    
  end
  
  def after_save #:nodoc:
    unless self.type == 'SOA' || @serial_updated 
      self.zone.soa_record.update_serial!
      @serial_updated = true
    end
  end
  
end
