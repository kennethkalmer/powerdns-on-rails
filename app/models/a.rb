# See #A

# = IPv4 Address Record (A)
#
# Defined in RFC 1035. Forward maps a host name to IPv4 address. The only
# parameter is an IP address in dotted decimal format. The IP address in not
# terminated with a '.' (dot). Valid host name format (a.k.a 'label' in DNS
# jargon). If host name is BLANK (or space) then the last valid name (or label)
# is substituted.
#
# Obtained from http://www.zytrax.com/books/dns/ch8/a.html
#
class A < Record

  # Only accept valid IPv4 addresses
  validates :content, :presence => true, :ip_address => true

end
