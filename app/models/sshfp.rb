# See #SSHFP

# = SSH Fingerprint (SSHFP)
# 
# Defined in RFC 4255.
#
class SSHFP < Record
  
  validates_format_of :content, :with => /^[1-3] [1-2] ([0-9a-f]{40})$/
  
end
