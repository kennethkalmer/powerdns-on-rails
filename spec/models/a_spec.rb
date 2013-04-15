require 'spec_helper'

describe A do

  context "new record" do

    it "should be invalid by default" do
      subject.should_not be_valid
    end

    it "should only accept valid IPv4 addresses as content" do
      subject.content = '10'
      subject.should have(1).error_on(:content)

      subject.content = '10.0'
      subject.should have(1).error_on(:content)

      subject.content = '10.0.0'
      subject.should have(1).error_on(:content)

      subject.content = '10.0.0.9/32'
      subject.should have(1).error_on(:content)

      subject.content = '256.256.256.256'
      subject.should have(1).error_on(:content)

      subject.content = '10.0.0.9'
      subject.should have(:no).error_on(:content)
    end

    it "should not accept new lines in content" do
      subject.content = "10.1.1.1\nHELLO WORLD"
      subject.should have(1).error_on(:content)
    end

    it "should not act as a CNAME" do
      subject.content = 'google.com'
      subject.should have(1).error_on(:content)
    end

  end

end
