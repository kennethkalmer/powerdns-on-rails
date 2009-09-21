require File.dirname(__FILE__) + '/../spec_helper'

describe AAAA, "when new" do

  before(:each) do
    @aaaa = AAAA.new
  end

  it "should be invalid by default" do
    @aaaa.should_not be_valid
  end

  it "should only accept IPv6 address as content"

  it "should not act as a CNAME" do
    @aaaa.content = 'google.com'
    @aaaa.should have(1).error_on(:content)
  end

  it "should accept a valid ipv6 address" do
    @aaaa.content = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    @aaaa.should have(:no).error_on(:content)
  end

  it "should not accept new lines in content" do
    @aaaa.content = "2001:0db8:85a3:0000:0000:8a2e:0370:7334\nHELLO WORLD"
    @aaaa.should have(1).error_on(:content)
  end

end
