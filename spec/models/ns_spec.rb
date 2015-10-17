require 'spec_helper'

describe NS do
  context "when new" do
    it "should be invalid by default" do
      expect(subject).not_to be_valid
    end

    it "should require content" do
      subject.valid?
      expect( subject.errors[:content].size ).to eq(2)
    end
  end
end
