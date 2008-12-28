require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Macro, "when new" do
  before(:each) do
    @macro = Macro.new
  end

  it "should require a new" do
    @macro.should have(1).error_on(:name)
  end

  it "should have a unique name" do
    m = Factory(:macro)
    @macro.name = m.name
    @macro.should have(1).error_on(:name)
  end

  it "should be disabled by default" do
    @macro.should_not be_active
  end
  
end

