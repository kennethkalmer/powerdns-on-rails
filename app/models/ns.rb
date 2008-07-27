# See #NS

# = Name Server Record (NS)
#
# Defined in RFC 1035. NS RRs appear in two places. Within the zone file, in 
# which case they are authoritative records for the zone's name servers. At the 
# point of delegation for either a subdomain of the zone or in the zone's 
# parent. Thus the zone example.com's parent zone (.com) will contain 
# non-authoritative NS RRs for the zone example.com at its point of delegation 
# and subdomain.example.com will have non-authoritative NS RSS in the zone 
# example.com at its point of delegation. NS RRs at the point of delegation are 
# never authoritative only NS RRs for the zone are regarded as authoritative. 
# While this may look a fairly trivial point, is has important implications for 
# DNSSEC.
#
# NS RRs are required because DNS queries respond with an authority section 
# listing all the authoritative name servers, for sub-domains or queries to the 
# zones parent where they are required to allow referral to take place.
# 
# Obtained from http://www.zytrax.com/books/dns/ch8/ns.html
# 
class NS < Record
  
  validates_presence_of :content
  
end
