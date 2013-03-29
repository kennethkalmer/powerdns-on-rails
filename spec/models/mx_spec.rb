require 'spec_helper'

describe MX do
  context "when new" do

    it "should be invalid by default" do
      subject.should_not be_valid
    end

    it "should require a priority" do
      subject.should have(1).error_on(:prio)
    end

    it "should only allow positive, numeric priorities, between 0 and 65535 (inclusive)" do
      subject.prio = -10
      subject.should have(1).error_on(:prio)

      subject.prio = 65536
      subject.should have(1).error_on(:prio)

      subject.prio = 'low'
      subject.should have(1).error_on(:prio)

      subject.prio = 10
      subject.should have(:no).errors_on(:prio)
    end

    it "should require content" do
      subject.should have(2).error_on(:content)
    end

    it "should not accept IP addresses as content" do
      subject.content = "127.0.0.1"
      subject.should have(1).error_on(:content)
    end

    it "should not accept spaces in content" do
      subject.content = 'spaced out.com'
      subject.should have(1).error_on(:content)
    end

    it "should support priorities" do
      subject.supports_prio?.should be_true
    end

  end
end
