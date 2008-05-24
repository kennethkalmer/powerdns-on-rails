class Zone < ActiveRecord::Base
  
  has_many :records
  
  has_one  :soa_record, :class_name => 'SOA'
  has_many :ns_records, :class_name => 'NS'
  has_many :mx_records, :class_name => 'MX'
  has_many :a_records,  :class_name => 'A'
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
