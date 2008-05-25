# See #SOA

# = Start of Authority Record
# Defined in RFC 1035. The SOA defines global parameters for the zone (domain). 
# There is only one SOA record allowed in a zone file.
# 
# Obtained from http://www.zytrax.com/books/dns/ch8/soa.html
# 
class SOA < Record
  
  validates_presence_of :primary_ns, :contact
  validates_numericality_of(
    :serial, :refresh, :retry, :expire,
    :greater_than_or_equal_to => 0
  )
  validates_numericality_of( # RFC2308
    :minimum, 
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 10800
  )
  validates_uniqueness_of :zone_id
  
  def initialize( *args ) #:nodoc:
    super
    
    # Generate a new serial number if needed
    self.serial = Time.now.strftime( "%Y%m%d01" ).to_i if self.serial.nil?
  end
  
  # Updates the serial number to the next logical one. Format of the generated
  # serial is YYYYMMDDNN, where NN is the number of the change for the day.
  # 01 for the first change, 02 the seconds, etc...
  def update_serial
    unless Record.batch_soa_updates.nil? 
      if Record.batch_soa_updates.include?( self.id )
        return
      end
      
      Record.batch_soa_updates << self.id
    end
    
    @serial_updated = true

    date_segment = Time.now.strftime( "%Y%m%d" )

    # Same day change?
    increment = if date_segment == self.serial.to_s[0,8]
      increment = self.serial.to_s[9,2].succ
    else
      "01"
    end

    self.serial = ( date_segment + increment.rjust(2, "0") ).to_i
    
  end
  
  # Same as #update_serial and saves the record
  def update_serial!
    update_serial
    save
  end
  
  def before_update #:nodoc:
    update_serial unless @serial_updated
  end
end
