require File.dirname(__FILE__) + '/../spec_helper'

describe Zone, "when new" do
  fixtures :all
  
  before(:each) do
    @zone = Zone.new
  end

  it "should be invalid by default" do
    @zone.should_not be_valid
  end
  
  it "should require a name" do
    @zone.should have(1).error_on(:name)
  end
  
  it "should not allow duplicate names" do
    @zone.name = "example.com"
    @zone.should have(1).error_on(:name)
  end
  
end

describe Zone, "when loaded" do
  fixtures :all
  
  before(:each) do
    @zone = zones(:example_com)
  end
  
  it "should have a name" do
    @zone.name.should eql('example.com')
  end
  
  it "should have an SOA record" do
    @zone.soa_record.should eql( records( :example_com_soa ) )
  end
  
  it "should have NS records" do
    ns = @zone.ns_records
    ns.should be_a_kind_of( Array )
    ns.should include( records( :example_com_ns_ns1 ) )
    ns.should include( records( :example_com_ns_ns2 ) )
  end
  
  it "should have MX records" do
    mx = @zone.mx_records
    mx.should be_a_kind_of( Array )
    mx.should include( records( :example_com_mx ) )
  end
  
  it "should have A records" do
    a = @zone.a_records
    a.should be_a_kind_of( Array )
    a.should include( records( :example_com_a ) )
  end
  
end