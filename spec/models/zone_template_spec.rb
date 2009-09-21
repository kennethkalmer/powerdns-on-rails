require File.dirname(__FILE__) + '/../spec_helper'

describe ZoneTemplate, "when new" do

  before(:each) do
    @zone_template = ZoneTemplate.new
  end

  it "should be invalid by default" do
    @zone_template.should_not be_valid
  end

  it "should require a name" do
    @zone_template.should have(1).error_on(:name)
  end

  it "should have a unique name" do
    Factory(:zone_template)
    @zone_template.name = "East Coast Data Center"
    @zone_template.should have(1).error_on(:name)
  end

  it "should require a TTL" do
    @zone_template.ttl = nil
    @zone_template.should have(1).error_on(:ttl)
  end

  it "should not require optional owner" do
    @zone_template.should have(:no).errors_on(:user_id)
  end
end

describe ZoneTemplate, "when loaded" do

  before(:each) do
    @zone_template = Factory( :zone_template )
    Factory(:template_soa, :zone_template => @zone_template)
  end

  it "should have record templates" do
    @zone_template.record_templates.should_not be_empty
  end

  it "should provide an easy way to build a zone" do
    zone = @zone_template.build('example.org')
    zone.should be_a_kind_of( Domain )
    zone.should be_valid
  end

  it "should have a sense of validity" do
    @zone_template.has_soa?.should be_true

    Factory( :zone_template, :name => 'West Coast Data Center' ).has_soa?.should_not be_true
  end
end

describe ZoneTemplate, "with scoped finders" do

  before(:each) do
    @quentin = Factory(:quentin)
    @zone_template = Factory(:zone_template, :user => @quentin)
    @other_template = Factory(:zone_template, :name => 'West Coast Data Center')
  end

  it "should return all templates without a user" do
    templates = ZoneTemplate.find( :all )
    templates.should_not be_empty
    templates.size.should be( ZoneTemplate.count )
  end

  it "should only return a user's templates if not an admin" do
    templates = ZoneTemplate.find( :all, :user => @quentin )
    templates.should_not be_empty
    templates.size.should be(1)
    templates.each { |z| z.user.should eql( @quentin ) }
  end

  it "should return all templates if the user is an admin" do
    templates = ZoneTemplate.find( :all, :user => Factory(:admin) )
    templates.should_not be_empty
    templates.size.should be( ZoneTemplate.count )
  end

  it "should support will_paginate (no user)" do
    pending
    templates = ZoneTemplate.paginate( :page => 1 )
    templates.should_not be_empty
    templates.size.should be( ZoneTemplate.count )
  end

  it "shoud support will_paginate (admin user)" do
    pending
    templates = ZoneTemplate.paginate( :page => 1, :user => users(:admin) )
    templates.should_not be_empty
    templates.size.should be( ZoneTemplate.count )
  end

  it "should support will_paginate (template owner)" do
    pending
    templates = ZoneTemplate.paginate( :page => 1, :user => users(:quentin) )
    templates.should_not be_empty
    templates.size.should be(1)
    templates.each { |z| z.user.should eql(users(:quentin)) }
  end
end

describe ZoneTemplate, "when used to build a zone" do

  before(:each) do
    @zone_template = Factory( :zone_template )
    Factory(:template_soa, :zone_template => @zone_template)
    Factory(:template_ns, :zone_template => @zone_template)
    Factory(:template_ns, :content => 'ns2.%ZONE%', :zone_template => @zone_template)

    @domain = @zone_template.build( 'example.org' )
  end

  it "should create a valid new zone" do
    @domain.should be_valid
    @domain.should be_a_kind_of( Domain )
  end

  it "should create the correct number of records (from templates)" do
    @domain.records.size.should eql( @zone_template.record_templates.size )
  end

  it "should create a SOA record" do
    soa = @domain.soa_record
    soa.should_not be_nil
    soa.should be_a_kind_of( SOA )
    soa.primary_ns.should eql('ns1.example.org')
  end

  it "should create two NS records" do
    ns = @domain.ns_records
    ns.should be_a_kind_of( Array )
    ns.size.should be(2)

    ns.each { |r| r.should be_a_kind_of( NS ) }
  end

end

describe ZoneTemplate, "when used to build a zone for a user" do

  before(:each) do
    @user = Factory(:quentin)
    @zone_template = Factory(:zone_template, :user => @quentin)
    Factory(:template_soa, :zone_template => @zone_template)
    Factory(:template_ns, :zone_template => @zone_template)
    Factory(:template_ns, :name => 'ns2.%ZONE%', :zone_template => @zone_template)
    Factory(:template_cname, :zone_template => @zone_template)
    Factory(:template_cname, :name => 'www.%ZONE%', :zone_template => @zone_template)

    @domain = @zone_template.build( 'example.org', @user )
  end

  it "should create a valid new zone" do
    @domain.should be_valid
    @domain.should be_a_kind_of( Domain )
  end

  it "should be owned by the user" do
    @domain.user.should be( @user )
  end

  it "should create the correct number of records (from templates)" do
    @domain.records.size.should eql( @zone_template.record_templates.size )
  end

  it "should create a SOA record" do
    soa = @domain.soa_record
    soa.should_not be_nil
    soa.should be_a_kind_of( SOA )
    soa.primary_ns.should eql('ns1.example.org')
  end

  it "should create two NS records" do
    ns = @domain.ns_records
    ns.should be_a_kind_of( Array )
    ns.size.should be(2)

    ns.each { |r| r.should be_a_kind_of( NS ) }
  end

  it "should create the correct CNAME's from the template" do
    cnames = @domain.cname_records
    cnames.size.should be(2)
  end

end

describe ZoneTemplate, "and finders" do

  before(:each) do
    zt1 = Factory(:zone_template)
    Factory(:template_soa, :zone_template => zt1 )

    Factory(:zone_template, :name => 'No SOA')
  end

  it "should be able to return all templates" do
    ZoneTemplate.find(:all).size.should be( ZoneTemplate.count )
  end

  it "should respect required validations" do
    ZoneTemplate.find(:all, :require_soa => true).size.should be( 1 )
  end
end
