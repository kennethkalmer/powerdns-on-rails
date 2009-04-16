# See #MX

# = Mail Exchange Record (MX)
# Defined in RFC 1035. Specifies the name and relative preference of mail 
# servers (mail exchangers in the DNS jargon) for the zone.
#
# Obtained from http://www.zytrax.com/books/dns/ch8/mx.html
#
class MX < Record
  
  validates_numericality_of :prio,
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 65535,
    :only_integer => true
  
  validates_presence_of :content
  
  # Only accept valid IPv4 addresses
  def validate_with_mx
    if content =~ /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
      errors.add('content', 'Cannot be an IP address')
    end
    validate_without_mx
  end
  alias_method_chain :validate, :mx

  def supports_prio?
    true
  end
end
