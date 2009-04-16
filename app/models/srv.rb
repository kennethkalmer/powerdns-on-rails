# See #SRV

# = Service Record (SRV)
#
# An SRV record or Service record is a category of data in the Internet Domain
# Name System specifying information on available services. It is defined in
# RFC 2782. Newer internet protocols such as SIP and XMPP often require SRV
# support from clients.
#
# Obtained from http://en.wikipedia.org/wiki/SRV_record
# 
# See also http://www.zytrax.com/books/dns/ch8/srv.html
#
class SRV < Record

  validates_numericality_of :prio,
    :greater_than_or_equal_to => 0
  
  validates_presence_of :content
  
  # We support priorities
  def supports_prio?
    true
  end
end
