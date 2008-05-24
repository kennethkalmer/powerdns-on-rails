require File.dirname(__FILE__) + '/../spec_helper'

describe SOA, "when new" do
  before(:each) do
    @soa = SOA.new
  end

  it "should be invalid by default" do
    @soa.should_not be_valid
  end
end
