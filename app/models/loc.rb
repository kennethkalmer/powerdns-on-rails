# See #LOC

# = Name Server Record (LOC)
#
# In the Domain Name System, a LOC record (RFC 1876) is a means for expressing
# geographic location information for a domain name.
# It contains WGS84 Latitude, Longitude and Altitude information together with
# host/subnet physical size and location accuracy. This information can be
# queried by other computers connected to the Internet.
#
# Obtained from http://en.wikipedia.org/wiki/LOC_record
#
class LOC < Record

  validates_presence_of :content

end
