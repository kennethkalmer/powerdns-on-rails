class Record < ActiveRecord::Base
  
  belongs_to :zone

  validates_presence_of :zone_id
  validates_associated :zone
  validates_numericality_of( 
    :ttl, 
    :greater_than_or_equal_to => 0, 
    :only_integer => true 
  )
  
end
