require 'spec_helper'

describe AAAA do

  context "when new" do

    it "should be invalid by default" do
      subject.should_not be_valid
    end

    it "should only accept IPv6 address as content"

    it "should not act as a CNAME" do
      subject.content = 'google.com'
      subject.should have(1).error_on(:content)
    end

    it "should accept a valid ipv6 address" do
      subject.content = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
      subject.should have(:no).error_on(:content)
    end

    it "should not accept new lines in content" do
      subject.content = "2001:0db8:85a3:0000:0000:8a2e:0370:7334\nHELLO WORLD"
      subject.should have(1).error_on(:content)
    end

  end

end
