require File.dirname(__FILE__) + '/../spec_helper'

describe MX, "when new" do
  before(:each) do
    @mx = MX.new
  end

  it "should be invalid by default" do
    @mx.should_not be_valid
  end
  
  it "should require a priority" do
    @mx.should have(1).error_on(:prio)
  end
  
  it "should only allow positive, numeric priorities" do
    @mx.prio = -10
    @mx.should have(1).error_on(:prio)
    
    @mx.prio = 'low'
    @mx.should have(1).error_on(:prio)
    
    @mx.prio = 10
    @mx.should have(:no).errors_on(:prio)
  end
  
  it "should require content" do
    @mx.should have(1).error_on(:content)
  end
  
end
