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

  validates :content, :presence => true, :hostname => true

  def supports_prio?
    true
  end
end
