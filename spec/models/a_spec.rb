require File.dirname(__FILE__) + '/../spec_helper'

describe A, "when new" do
  before(:each) do
    @a = A.new
  end

  it "should be invalid by default" do
    @a.should_not be_valid
  end
  
  it "should only accept valid IPv4 addresses as data" do
    @a.data = '10'
    @a.should have(1).error_on(:data)
    
    @a.data = '10.0'
    @a.should have(1).error_on(:data)
    
    @a.data = '10.0.0'
    @a.should have(1).error_on(:data)
    
    @a.data = '10.0.0.9/32'
    @a.should have(1).error_on(:data)
    
    @a.data = '256.256.256.256'
    @a.should have(1).error_on(:data)
    
    @a.data = '10.0.0.9'
    @a.should have(:no).error_on(:data)
  end
  
  it "should not act as a CNAME" do
    @a.data = 'google.com'
    @a.should have(1).error_on(:data)
  end
  
end
