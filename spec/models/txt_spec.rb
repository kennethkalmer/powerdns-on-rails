require File.dirname(__FILE__) + '/../spec_helper'

describe TXT, "when new" do
  before(:each) do
    @txt = TXT.new
  end

  it "should be invalid by default" do
    @txt.should_not be_valid
  end
  
  it "should require data" do
    @txt.should have(1).error_on(:data)
  end
  
  it "should wrap the data in quotes" do
    @txt.data = "google.com"
    @txt.data.should eql('"google.com"')
  end
end
