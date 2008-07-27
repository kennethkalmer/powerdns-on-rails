require File.dirname(__FILE__) + '/../spec_helper'

describe Domain, "when new" do
  fixtures :all
  
  before(:each) do
    @domain = Domain.new
  end

  it "should be invalid by default" do
    @domain.should_not be_valid
  end
  
  it "should require a name" do
    @domain.should have(1).error_on(:name)
  end
  
  it "should not allow duplicate names" do
    @domain.name = "example.com"
    @domain.should have(1).error_on(:name)
  end
  
  it "should bail out on missing SOA fields" do
    @domain.should have(1).error_on( :primary_ns )
  end
  
  it "should be NATIVE by default" do
    @domain.type.should eql('NATIVE')
  end
end

describe Domain, "when loaded" do
  fixtures :all
  
  before(:each) do
    @domain = domains(:example_com)
  end
  
  it "should have a name" do
    @domain.name.should eql('example.com')
  end
  
  it "should have an SOA record" do
    @domain.soa_record.should eql( records( :example_com_soa ) )
  end
  
  it "should have NS records" do
    ns = @domain.ns_records
    ns.should be_a_kind_of( Array )
    ns.should include( records( :example_com_ns_ns1 ) )
    ns.should include( records( :example_com_ns_ns2 ) )
  end
  
  it "should have MX records" do
    mx = @domain.mx_records
    mx.should be_a_kind_of( Array )
    mx.should include( records( :example_com_mx ) )
  end
  
  it "should have A records" do
    a = @domain.a_records
    a.should be_a_kind_of( Array )
    a.should include( records( :example_com_a ) )
  end
  
  it "should give access to all records excluding the SOA" do
    @domain.records_without_soa.size.should be( @domain.records.size - 1 )
  end
  
  it "should not complain about missing SOA fields" do
    @domain.should have(:no).errors_on(:primary_ns)
  end
end

describe Domain, "with scoped finders" do
  fixtures :all
  
  it "should return all zones without a user" do
    domains = Domain.find( :all )
    domains.should_not be_empty
    domains.size.should be( Domain.count )
  end
  
  it "should only return a user's zones if not an admin" do
    domains = Domain.find( :all, :user => users(:quentin) )
    domains.should_not be_empty
    domains.size.should be(1)
    domains.each { |z| z.user.should eql( users( :quentin ) ) }
  end
  
  it "should return all zones if the user is an admin" do
    domains = Domain.find( :all, :user => users(:admin) )
    domains.should_not be_empty
    domains.size.should be( Domain.count )
  end
  
  it "should support will_paginate (no user)" do
    domains = Domain.paginate( :page => 1 )
    domains.should_not be_empty
    domains.size.should be( Domain.count )
  end
  
  it "shoud support will_paginate (admin user)" do
    domains = Domain.paginate( :page => 1, :user => users(:admin) )
    domains.should_not be_empty
    domains.size.should be( Domain.count )
  end
  
  it "should support will_paginate (zone owner)" do
    domains = Domain.paginate( :page => 1, :user => users(:quentin) )
    domains.should_not be_empty
    domains.size.should be(1)
    domains.each { |z| z.user.should eql(users(:quentin)) }
  end
end

describe Domain, "when created" do
  fixtures :all
  
  before(:each) do
    @domain = Domain.new
  end
  
  it "with additional attributes should create an SOA record" do
    @domain.name = 'example.org'
    @domain.primary_ns = 'ns1.example.org'
    @domain.contact = 'admin@example.org'
    @domain.refresh = 10800
    @domain.retry = 7200
    @domain.expire = 604800
    @domain.minimum = 10800
    
    @domain.save.should be_true
    @domain.soa_record.should_not be_nil
    @domain.soa_record.primary_ns.should eql('ns1.example.org')
  end
end

describe Domain, "when deleting" do
  fixtures :all
  
  it "should delete its records as well" do
    @domain = domains(:example_com)
    lambda { @domain.destroy }.should change(Record, :count).by(-8)
    
  end
end

describe Domain, "when searching" do
  fixtures :all
  
  it "should return results for admins" do
    Domain.search('exa', 1, users(:admin)).should_not be_empty
  end
  
  it "should return results for users" do
    Domain.search('exa', 1, users(:quentin)).should_not be_empty
  end
  
  it "should return unscoped results" do
    Domain.search('exa', 1).should_not be_empty
  end
end