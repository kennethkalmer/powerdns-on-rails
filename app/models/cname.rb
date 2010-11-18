# See #CNAME

# = Canonical Name Record (CNAME)
#
# A CNAME record maps an alias or nickname to the real or Canonical name which
# may lie outside the current zone. Canonical means expected or real name.
#
# Obtained from http://www.zytrax.com/books/dns/ch8/cname.html
#
class CNAME < Record

  validates :content, :presence => true, :hostname => true

end
