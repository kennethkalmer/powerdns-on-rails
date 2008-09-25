require File.dirname(__FILE__) + '/../../spec_helper'

describe "/audits/domain", "and domain audits" do 
  
  it "should handle no audit entries on the domain" do
    pending
  end
  
  it "should handle audit entries on the domain" do
    pending
  end
  
end

describe "/audits/domain", "and resource record audits" do
  
  it "should handle no audit entries" do
    pending
  end
  
  it "should handle entries with a 'type' key in change hash" do
    pending
  end
  
  it "should handle entries without a 'type' key in the change hash, but existing record" do
    pending
  end
  
  it "should handle entries without a 'type' key in the change hash, and without a record" do
    pending
  end
  
end
