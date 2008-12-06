require File.dirname(__FILE__) + '/../spec_helper'

describe AAAA, "when new" do
  
  before(:each) do
    @aaaa = AAAA.new
  end
  
  it "should be invalid by default" do
    @aaaa.should_not be_valid
  end
  
  it "should only accept IPv6 address as content" 
  
  it "should not act as a CNAME" do
    @aaaa.content = 'google.com'
    @aaaa.should have(1).error_on(:content)
  end
  
end
