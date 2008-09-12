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
  fixtures :all
  
  before(:each) do
    @record_template = RecordTemplate.new
    @record_template.zone_template = zone_templates(:east_coast_dc)
  end
  
  it "validations from A" do
    @record_template.record_type = 'A'
    @record_template.should_not be_valid
    
    @record_template.content = '256.256.256.256'
    @record_template.should have(1).error_on(:content)
    
    @record_template.content = 'google.com'
    @record_template.should have(1).error_on(:content)
    
    @record_template.content = '10.0.0.9'
    @record_template.should have(:no).error_on(:content)
  end
  
  it "validations from CNAME" do
    @record_template.record_type = 'NS'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:content)
  end
  
  it "validations from MX" do
    @record_template.record_type = 'MX'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:prio)
    @record_template.should have(1).error_on(:content)
    
    @record_template.prio = -10
    @record_template.should have(1).error_on(:prio)
    
    # FIXME: Why is priority 0 at this stage?
    #@record_template.prio = 'low'
    #@record_template.should have(1).error_on(:prio)
    
    @record_template.prio = 10
    @record_template.should have(:no).errors_on(:prio)
  end
  
  it "validations from NS" do
    @record_template.record_type = 'NS'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:content)
  end
  
  it "validations from TXT" do
    @record_template.record_type = 'TXT'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:content)
  end
  
  it "validations from SOA" do
    @record_template.record_type = 'SOA'
    @record_template.should_not be_valid
    
    @record_template.should have(1).error_on(:primary_ns)
    @record_template.should have(1).error_on(:contact)
  end
  
  it "convenience methods from SOA" do
    @record_template.record_type = 'SOA'
    
    @record_template.primary_ns = 'ns1.%ZONE%'
    @record_template.contact = 'admin@example.com'
    @record_template.refresh = 7200
    @record_template.retry = 1800
    @record_template.expire = 604800
    @record_template.minimum = 10800
    
    @record_template.content.should eql('ns1.%ZONE% admin@example.com 0 7200 1800 604800 10800')
    @record_template.should be_valid
    @record_template.save.should be_true
  end
end

describe RecordTemplate, "when building" do
  fixtures :all
  
  it "an SOA should replace the %ZONE% token with the provided domain name" do
    template = record_templates( :east_coast_soa )
    record = template.build( 'example.org' )
    
    record.should_not be_nil
    record.should be_a_kind_of( SOA )
    record.primary_ns.should eql('ns1.example.org')
  end
  
  it "an NS should replace the %ZONE% token with the provided domain name" do
    template = record_templates( :east_coast_ns_ns1 )
    record = template.build( 'example.org' )
    
    record.should_not be_nil
    record.should be_a_kind_of( NS )
    record.content.should eql('ns1.example.org')
  end
  
  it "a MX should replace the %ZONE% token with provided domain name" do
    template = record_templates( :east_coast_mx )
    record = template.build( 'example.org' )
    
    record.should_not be_nil
    record.should be_a_kind_of( MX )
    record.content.should eql('mail.example.org')
  end
end

describe RecordTemplate, "when creating" do
  fixtures :all
  
  it "should inherit the TTL from the ZoneTemplate" do
    zone_template = zone_templates( :east_coast_dc )
    record_template = RecordTemplate.new( :zone_template => zone_template )
    record_template.record_type = 'A'
    record_template.content = '10.0.0.1'
    record_template.save.should be_true
    
    record_template.ttl.should be(zone_template.ttl)
  end
  
  it "should prefer own TTL over that of the ZoneTemplate" do
    zone_template = zone_templates( :east_coast_dc )
    record_template = RecordTemplate.new( :zone_template => zone_template )
    record_template.record_type = 'A'
    record_template.content = '10.0.0.1'
    record_template.ttl = 43200
    record_template.save.should be_true
    
    record_template.ttl.should be(43200)
  end
end

describe RecordTemplate, "when loaded" do
  fixtures :all
  
  it "should have SOA convenience, if an SOA template" do
    record_template = record_templates(:east_coast_soa)
    record_template.primary_ns.should eql('ns1.%ZONE%')
    record_template.retry.should be(7200)
  end
end

describe RecordTemplate, "when updated" do
  fixtures :all
  
  it "should handle SOA convenience" do
    record_template = record_templates(:east_coast_soa)
    record_template.primary_ns = 'ns1.provider.net'
    
    record_template.save
    record_template.reload
    
    record_template.primary_ns.should eql('ns1.provider.net')
  end
end
