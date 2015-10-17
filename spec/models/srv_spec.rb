require 'spec_helper'

describe SRV do
  it "should support priorities" do
    expect(subject.supports_prio?).to be_truthy
  end
end
