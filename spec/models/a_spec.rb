require File.dirname(__FILE__) + '/../spec_helper'

describe A, "when new" do
  before(:each) do
    @a = A.new
  end

  it "should be invalid by default" do
    @a.should_not be_valid
  end
end
