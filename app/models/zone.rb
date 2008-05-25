# See #Zone

# = Zone
# 
# A #Zone is a unique domain name entry, and contains various #Record entries to
# represent its data.
# 
# The zone is used for the following purposes:
# * It is the $ORIGIN off all its records
# * It specifies a default $TTL
# * Speedy lookups by bind-dlz to determine if its authorative
# 
class Zone < ActiveRecord::Base
  
  has_many :records
  
  has_one  :soa_record,    :class_name => 'SOA'
  has_many :ns_records,    :class_name => 'NS'
  has_many :mx_records,    :class_name => 'MX'
  has_many :a_records,     :class_name => 'A'
  has_many :txt_records,   :class_name => 'TXT'
  has_many :cname_records, :class_name => 'CNAME'
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
