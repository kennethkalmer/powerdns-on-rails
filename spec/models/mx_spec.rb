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
  
  it "should only allow positive, numeric priorities, between 0 and 65535 (inclusive)" do
    @mx.prio = -10
    @mx.should have(1).error_on(:prio)
    
    @mx.prio = 65536
    @mx.should have(1).error_on(:prio)
    
    @mx.prio = 'low'
    @mx.should have(1).error_on(:prio)
    
    @mx.prio = 10
    @mx.should have(:no).errors_on(:prio)
  end
  
  it "should require content" do
    @mx.should have(1).error_on(:content)
  end
  
  it "should not accept IP addresses as content" do
    @mx.content = "127.0.0.1"
    @mx.should have(1).error_on(:content)
  end

  it "should not accept spaces in content" do
    @mx.content = 'spaced out.com'
    @mx.should have(1).error_on(:content)
  end

  it "should support priorities" do
    @mx.supports_prio?.should be_true
  end
  
end
