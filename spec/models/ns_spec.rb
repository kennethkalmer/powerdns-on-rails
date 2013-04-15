require 'spec_helper'

describe NS do
  context "when new" do
    it "should be invalid by default" do
      subject.should_not be_valid
    end

    it "should require content" do
      subject.should have(2).error_on(:content)
    end
  end
end
