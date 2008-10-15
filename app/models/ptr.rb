# See #PTR

# = Name Server Record (PTR)
#
# Pointer records are the opposite of A and AAAA RRs and are used in Reverse Map
# zone files to map an IP address (IPv4 or IPv6) to a host name.
#
# Obtained from http://www.zytrax.com/books/dns/ch8/ptr.html
#
class PTR < Record

  validates_presence_of :content

end
