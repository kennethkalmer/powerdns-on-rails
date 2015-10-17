require 'spec_helper'

describe AAAA do

  context "when new" do

    it "should be invalid by default" do
      expect(subject).not_to be_valid
    end

    it "should only accept IPv6 address as content"

    it "should not act as a CNAME" do
      subject.content = 'google.com'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

    it "should accept a valid ipv6 address" do
      subject.content = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
      subject.valid?
      expect( subject.errors[:content].size ).to eq(0)
    end

    it "should not accept new lines in content" do
      subject.content = "2001:0db8:85a3:0000:0000:8a2e:0370:7334\nHELLO WORLD"
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

  end

end
