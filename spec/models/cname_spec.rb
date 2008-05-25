require File.dirname(__FILE__) + '/../spec_helper'

describe CNAME, "when new" do
  before(:each) do
    @cname = CNAME.new
  end

  it "should be invalid by default" do
    @cname.should_not be_valid
  end
  
  it "should require data" do
    @cname.should have(1).error_on(:data)
  end
end
