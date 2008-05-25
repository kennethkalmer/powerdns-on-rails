require File.dirname(__FILE__) + '/../spec_helper'

describe MX, "when new" do
  before(:each) do
    @mx = MX.new
  end

  it "should be invalid by default" do
    @mx.should_not be_valid
  end
  
  it "should require a priority" do
    @mx.should have(1).error_on(:priority)
  end
  
  it "should only allow positive, numeric priorities" do
    @mx.priority = -10
    @mx.should have(1).error_on(:priority)
    
    @mx.priority = 'low'
    @mx.should have(1).error_on(:priority)
    
    @mx.priority = 10
    @mx.should have(:no).errors_on(:priority)
  end
  
  it "should require data" do
    @mx.should have(1).error_on(:data)
  end
  
end
