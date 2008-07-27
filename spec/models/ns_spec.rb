require File.dirname(__FILE__) + '/../spec_helper'

describe NS, "when new" do
  before(:each) do
    @ns = NS.new
  end

  it "should be invalid by default" do
    @ns.should_not be_valid
  end
  
  it "should require content" do
    @ns.should have(1).error_on(:content)
  end
  
end
