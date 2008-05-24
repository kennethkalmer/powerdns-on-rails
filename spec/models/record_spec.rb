require File.dirname(__FILE__) + '/../spec_helper'

describe Record, "in general" do
  before(:each) do
    @record = Record.new
  end

  it "should be invalid by default" do
    @record.should_not be_valid
  end
  
  it "should require a zone" do
    @record.should have(1).error_on(:zone_id)
  end
  
  it "should require a ttl" do
    @record.should have(1).error_on(:ttl)
  end
  
  it "should only allow positive numeric ttl's" do
    @record.ttl = -100
    @record.should have(1).error_on(:ttl)
    
    @record.ttl = '2d'
    @record.should have(1).error_on(:ttl)
    
    @record.ttl = 86400
    @record.should have(:no).errors_on(:ttl)
  end
  
  it "should have @ as the host be default" do
    @record.host.should eql('@')
  end
  
end
