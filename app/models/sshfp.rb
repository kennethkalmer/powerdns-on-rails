# See #SSHFP

# = SSH Fingerprint (SSHFP)
# 
# Defined in RFC 4255.
#
# Including draft extension for SHA2 and ECDSA. See https://tools.ietf.org/html/draft-os-ietf-sshfp-ecdsa-sha2-04

class SSHFP < Record
  
  validates_format_of :content, :with => /^[1-3] [1-2] ([0-9a-fA-F]{40}|[0-9a-fA-F]{64})$/

end
