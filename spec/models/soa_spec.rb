require File.dirname(__FILE__) + '/../spec_helper'

describe SOA, "when new" do
  before(:each) do
    @soa = SOA.new
  end

  it "should be invalid by default" do
    @soa.should_not be_valid
  end
  
  it "should require a primary NS" do
    @soa.should have(1).error_on(:primary_ns)
  end
  
  it "should require a contact" do
    @soa.should have(1).error_on(:contact)
  end
  
  it "should require a serial" do
    @soa.should have(1).error_on(:serial)
  end
  
  it "should require a refresh time" do
    @soa.should have(1).error_on(:refresh)
  end
  
  it "should require a retry time" do
    @soa.should have(1).error_on(:retry)
  end
  
  it "should require a expiry time" do
    @soa.should have(1).error_on(:expire)
  end
  
  it "should require a minimum time" do
    @soa.should have(1).error_on(:minimum)
  end
  
end
