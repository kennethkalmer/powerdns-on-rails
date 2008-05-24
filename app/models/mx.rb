class MX < Record
  
  validates_numericality_of(
    :priority,
    :greater_than_or_equal_to => 0
  )
  
end
