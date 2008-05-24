require File.dirname(__FILE__) + '/../spec_helper'

describe NS, "when new" do
  before(:each) do
    @ns = NS.new
  end

  it "should be invalid by default" do
    @ns.should_not be_valid
  end
end
