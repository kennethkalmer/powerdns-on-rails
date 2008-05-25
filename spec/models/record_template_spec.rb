require File.dirname(__FILE__) + '/../spec_helper'

describe RecordTemplate, "when new" do
  fixtures :all
  
  before(:each) do
    @record_template = RecordTemplate.new
  end

  it "should be invalid by default" do
    @record_template.should_not be_valid
  end
  
end

describe RecordTemplate, "should inherit" do
  before(:each) do
    @record_template = RecordTemplate.new
  end
  
  it "validations from A" do
    @record_template.record_type = 'A'
    @record_template.should_not be_valid
    
    @record_template.data = '256.256.256.256'
    @record_template.should have(1).error_on(:data)
    
    @record_template.data = 'google.com'
    @record_template.should have(1).error_on(:data)
    
    @record_template.data = '10.0.0.9'
    @record_template.should have(:no).error_on(:data)
  end
  
  it "validations from CNAME" do
    @record_template.record_type = 'NS'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:data)
  end
  
  it "validations from MX" do
    @record_template.record_type = 'MX'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:priority)
    @record_template.should have(1).error_on(:data)
    
    @record_template.priority = -10
    @record_template.should have(1).error_on(:priority)
    
    # FIXME: Why is priority 0 at this stage?
    #@record_template.priority = 'low'
    #@record_template.should have(1).error_on(:priority)
    
    @record_template.priority = 10
    @record_template.should have(:no).errors_on(:priority)
  end
  
  it "validations from NS" do
    @record_template.record_type = 'NS'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:data)
  end
  
  it "validations from SOA" do
    @record_template.record_type = 'SOA'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:primary_ns)
    @record_template.should have(1).error_on(:contact)
  end
  
  it "validations from TXT" do
    @record_template.record_type = 'TXT'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:data)
  end
end
