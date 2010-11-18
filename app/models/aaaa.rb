# See #AAAA

# = IPv6 Address Record (AAAA)
#
# The current IETF recommendation is to use AAAA (Quad A) RR for forward mapping
# and PTR RRs for reverse mapping when defining IPv6 networks. The IPv6 AAAA RR
# is defined in RFC 3596. RFC 3363 changed the status of the A6 RR (defined in
# RFC 2874 from a PROPOSED STANDARD to EXPERIMENTAL due primarily to performance
# and operational concerns.
#
# Obtained from http://www.zytrax.com/books/dns/ch8/aaaa.html
#
class AAAA < Record

  # Only accept valid IPv6 addresses
  validates :content, :presence => true, :ip_address => { :ipv6 => true }

end
