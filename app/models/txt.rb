# See #TXT

# = Text Record (TXT)
# Provides the ability to associate some text with a host or other name. The TXT
# record is used to define the Sender Policy Framework (SPF) information record 
# which may be used to validate legitimate email sources from a domain. The SPF 
# record while being increasing deployed is not (July 2004) a formal IETF RFC 
# standard.
# 
# Obtained from http://www.zytrax.com/books/dns/ch8/txt.html
class TXT < Record
  
  validates_presence_of :content
  
end
