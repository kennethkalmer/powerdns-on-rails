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
  
  validates_presence_of :data
  
  # Wrap the text in double quotes
  def data=( txt )
    if txt.nil?
      self[:data] = nil
      return
    end
    
    txt.insert( 0, '"' ) unless txt[ 0,1 ] == '"'
    txt << '"' unless txt[ txt.length, 1 ] == '"'
    
    self[:data] = txt
  end
  
end
