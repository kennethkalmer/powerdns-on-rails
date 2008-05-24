class SOA < Record
  
  validates_presence_of :primary_ns, :contact
  validates_numericality_of(
    :serial, :refresh, :retry, :expire, :minimum,
    :greater_than_or_equal_to => 0
  )
end
