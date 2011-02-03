require 'spec_helper'

describe SRV do
  before(:each) do
    @srv = SRV.new
  end
  
  it "should have tests" 

  it "should support priorities" do
    @srv.supports_prio?.should be_true
  end
end
