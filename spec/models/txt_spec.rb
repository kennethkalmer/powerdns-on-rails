require File.dirname(__FILE__) + '/../spec_helper'

describe TXT, "when new" do
  before(:each) do
    @txt = TXT.new
  end

  it "should be invalid by default" do
    @txt.should_not be_valid
  end
  
  it "should require content" do
    @txt.should have(1).error_on(:content)
  end
  
  it "should not tamper with content" do
    @txt.content = "google.com"
    @txt.content.should eql("google.com")
  end
end
