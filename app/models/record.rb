# See #Record

# = Record
# 
# The parent class for all our DNS RR's. Used to apply global rules and logic
# that can easily be applied to any DNS RR's
#
class Record < ActiveRecord::Base
  
  belongs_to :domain

  validates_presence_of :domain_id, :name
  validates_numericality_of( 
    :ttl,
    :greater_than_or_equal_to => 0, 
    :only_integer => true
  )
  
  class_inheritable_accessor :batch_soa_updates
  
  # This is needed here for generic form support, actual functionality 
  # implemented in #SOA
  attr_accessor :primary_ns, :contact, :refresh, :retry, :expire, :minimum
  
  before_save :update_change_date
  after_save  :update_soa_serial
  
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
  
  def shortname
    self[:name].gsub( /\.?#{self.domain.name}$/, '' )
  end
  
  def shortname=( value )
    self[:name] = value
  end
  
  # Pull in the name & TTL from the domain if missing
  def before_validation #:nodoc:
    unless self.domain_id.nil?
      append_domain_name!
      self.ttl ||= self.domain.ttl
    end
  end
  
  # Update the change date for automatic serial number generation
  def update_change_date
    self.change_date = Time.now.to_i
  end
  
  def update_soa_serial #:nodoc:
    unless self.type == 'SOA' || @serial_updated 
      self.domain.soa_record.update_serial!
      @serial_updated = true
    end
  end
  
  private
  
  # Append the domain name to the +name+ field if missing
  def append_domain_name!
    self[:name] = self.domain.name if self[:name].blank?
    
    self[:name] << ".#{self.domain.name}" unless self[:name].index( self.domain.name )
  end
end
