require 'spec_helper'

describe SRV do
  it "should support priorities" do
    subject.supports_prio?.should be_true
  end
end
