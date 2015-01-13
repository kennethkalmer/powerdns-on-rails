require 'spec_helper'

describe MX do
  context "when new" do

    it "should be invalid by default" do
      expect(subject).not_to be_valid
    end

    it "should require a priority" do
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(1)
    end

    it "should only allow positive, numeric priorities, between 0 and 65535 (inclusive)" do
      subject.prio = -10
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(1)

      subject.prio = 65536
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(1)

      subject.prio = 'low'
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(1)

      subject.prio = 10
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(0)
    end

    it "should require content" do
      expect(subject).to have(2).error_on(:content)
    end

    it "should not accept IP addresses as content" do
      subject.content = "127.0.0.1"
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

    it "should not accept spaces in content" do
      subject.content = 'spaced out.com'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

    it "should support priorities" do
      expect(subject.supports_prio?).to be_truthy
    end

  end
end
