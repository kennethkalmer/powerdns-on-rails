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
  
  it "should bail out on missing SOA fields" do
    @zone.should have(1).error_on( :primary_ns )
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
  
  it "should give access to all records excluding the SOA" do
    @zone.records_without_soa.size.should be( @zone.records.size - 1 )
  end
  
  it "should not complain about missing SOA fields" do
    @zone.should have(:no).errors_on(:primary_ns)
  end
end

describe Zone, "with scoped finders" do
  fixtures :all
  
  it "should return all zones without a user" do
    zones = Zone.find( :all )
    zones.should_not be_empty
    zones.size.should be( Zone.count )
  end
  
  it "should only return a user's zones if not an admin" do
    zones = Zone.find( :all, :user => users(:quentin) )
    zones.should_not be_empty
    zones.size.should be(1)
    zones.each { |z| z.user.should eql( users( :quentin ) ) }
  end
  
  it "should return all zones if the user is an admin" do
    zones = Zone.find( :all, :user => users(:admin) )
    zones.should_not be_empty
    zones.size.should be( Zone.count )
  end
  
  it "should support will_paginate (no user)" do
    zones = Zone.paginate( :page => 1 )
    zones.should_not be_empty
    zones.size.should be( Zone.count )
  end
  
  it "shoud support will_paginate (admin user)" do
    zones = Zone.paginate( :page => 1, :user => users(:admin) )
    zones.should_not be_empty
    zones.size.should be( Zone.count )
  end
  
  it "should support will_paginate (zone owner)" do
    zones = Zone.paginate( :page => 1, :user => users(:quentin) )
    zones.should_not be_empty
    zones.size.should be(1)
    zones.each { |z| z.user.should eql(users(:quentin)) }
  end
end

describe Zone, "when created" do
  fixtures :all
  
  before(:each) do
    @zone = Zone.new
  end
  
  it "with additional attributes should create an SOA record" do
    @zone.name = 'example.org'
    @zone.primary_ns = 'ns1.example.org'
    @zone.contact = 'admin@example.org'
    @zone.refresh = 10800
    @zone.retry = 7200
    @zone.expire = 604800
    @zone.minimum = 10800
    
    @zone.save.should be_true
    @zone.soa_record.should_not be_nil
    @zone.soa_record.primary_ns.should eql('ns1.example.org')
  end
end

describe Zone, "when deleting" do
  fixtures :all
  
  it "should delete its records as well" do
    @zone = zones(:example_com)
    lambda { @zone.destroy }.should change(Record, :count).by(-8)
    
  end
end

describe Zone, "when searching" do
  fixtures :all
  
  it "should return results when valid" do
    Zone.search('exa').should_not be_empty
  end
end