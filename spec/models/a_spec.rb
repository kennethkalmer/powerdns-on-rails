require 'spec_helper'

describe A do

  context "new record" do

    it "should be invalid by default" do
      expect(subject).not_to be_valid
    end

    it "should only accept valid IPv4 addresses as content" do
      subject.content = '10'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)

      subject.content = '10.0'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)

      subject.content = '10.0.0'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)

      subject.content = '10.0.0.9/32'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)

      subject.content = '256.256.256.256'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)

      subject.content = '10.0.0.9'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(0)
    end

    it "should not accept new lines in content" do
      subject.content = "10.1.1.1\nHELLO WORLD"
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

    it "should not act as a CNAME" do
      subject.content = 'google.com'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

  end

end
