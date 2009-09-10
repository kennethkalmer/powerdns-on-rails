require File.dirname(__FILE__) + '/../spec_helper'

describe A, "when new" do
  before(:each) do
    @a = A.new
  end

  it "should be invalid by default" do
    @a.should_not be_valid
  end
  
  it "should only accept valid IPv4 addresses as content" do
    @a.content = '10'
    @a.should have(1).error_on(:content)
    
    @a.content = '10.0'
    @a.should have(1).error_on(:content)
    
    @a.content = '10.0.0'
    @a.should have(1).error_on(:content)
    
    @a.content = '10.0.0.9/32'
    @a.should have(1).error_on(:content)
    
    @a.content = '256.256.256.256'
    @a.should have(1).error_on(:content)
    
    @a.content = '10.0.0.9'
    @a.should have(:no).error_on(:content)
  end
  
  it "should not accept new lines in content" do 
    @a.content = "10.1.1.1\nHELLO WORLD"
    @a.should have(1).error_on(:content)
  end
  
  it "should not act as a CNAME" do
    @a.content = 'google.com'
    @a.should have(1).error_on(:content)
  end
  
end
