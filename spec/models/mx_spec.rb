require File.dirname(__FILE__) + '/../spec_helper'

describe MX, "when new" do
  before(:each) do
    @mx = MX.new
  end

  it "should be invalid by default" do
    @mx.should_not be_valid
  end
  
end
