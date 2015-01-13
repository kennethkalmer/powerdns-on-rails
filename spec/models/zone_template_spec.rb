require 'spec_helper'

describe ZoneTemplate, "when new" do

  it "should be invalid by default" do
    expect(subject).not_to be_valid
  end

  it "should require a name" do
    subject.valid?
    expect( subject.errors[:name].size ).to eq(1)
  end

  it "should have a unique name" do
    FactoryGirl.create(:zone_template)
    subject.name = "East Coast Data Center"
    subject.valid?
    expect( subject.errors[:name].size ).to eq(1)
  end

  it "should require a TTL" do
    subject.ttl = nil
    subject.valid?
    expect( subject.errors[:ttl].size ).to eq(1)
  end

  it "should not require optional owner" do
    subject.valid?
    expect( subject.errors[:user_id].size ).to eq(0)
  end

  it "should require a master if it is a slave" do
    subject.type = 'SLAVE'
    subject.valid?
    expect( subject.errors[:master].size ).to eq(1)
  end
end

describe ZoneTemplate, "when loaded" do

  subject { FactoryGirl.create(:zone_template) }

  before(:each) do
    FactoryGirl.create(:template_soa, :zone_template => subject)
  end

  it "should have record templates" do
    expect(subject.record_templates).not_to be_empty
  end

  it "should provide an easy way to build a zone" do
    zone = subject.build('example.org')
    expect(zone).to be_a_kind_of( Domain )
    expect(zone).to be_valid
  end

  it "should have a sense of validity" do
    expect(subject.has_soa?).to be_truthy

    expect(FactoryGirl.create( :zone_template, :name => 'West Coast Data Center' ).has_soa?).not_to be_truthy
  end
end

describe ZoneTemplate, "with scopes" do

  let(:quentin) { FactoryGirl.create(:quentin) }

  subject { FactoryGirl.create(:zone_template, :user => quentin) }

  before(:each) do
    @other_template = FactoryGirl.create(:zone_template, :name => 'West Coast Data Center')
  end

  it "should only return a user's templates if not an admin" do
    subject # Sigh...
    templates = ZoneTemplate.user(quentin).all
    expect(templates).not_to be_empty
    expect(templates.size).to be(1)
    templates.each { |z| expect(z.user).to eql( quentin ) }
  end

  it "should return all templates if the user is an admin" do
    templates = ZoneTemplate.user(FactoryGirl.create(:admin)).all
    expect(templates).not_to be_empty
    expect(templates.size).to be( ZoneTemplate.count )
  end

  it "should return only valid records" do
    templates = ZoneTemplate.with_soa.all
    expect(templates).to be_empty

    FactoryGirl.create(:template_soa, :zone_template => subject)
    expect(ZoneTemplate.with_soa.all).not_to be_empty
  end
end

describe ZoneTemplate, "when used to build a zone" do

  subject { FactoryGirl.create(:zone_template) }

  before(:each) do
    FactoryGirl.create(:template_soa, :zone_template => subject)
    FactoryGirl.create(:template_ns, :zone_template => subject)
    FactoryGirl.create(:template_ns, :content => 'ns2.%ZONE%', :zone_template => subject)

    @domain = subject.build( 'example.org' )
  end

  it "should create a valid new zone" do
    expect(@domain).to be_valid
    expect(@domain).to be_a_kind_of( Domain )
  end

  it "should create the correct number of records (from templates)" do
    expect(@domain.records.size).to eql( subject.record_templates.size )
  end

  it "should create a SOA record" do
    soa = @domain.soa_record
    expect(soa).not_to be_nil
    expect(soa).to be_a_kind_of( SOA )
    expect(soa.primary_ns).to eql('ns1.example.org')
  end

  it "should create two NS records" do
    ns = @domain.ns_records
    expect(ns).to be_a_kind_of( Array )
    expect(ns.size).to be(2)

    ns.each { |r| expect(r).to be_a_kind_of( NS ) }
  end

end

describe ZoneTemplate, "when used to build a zone for a user" do

  subject { FactoryGirl.create(:zone_template) }

  before(:each) do
    @user = FactoryGirl.create(:quentin)
    FactoryGirl.create(:template_soa, :zone_template => subject)
    FactoryGirl.create(:template_ns, :zone_template => subject)
    FactoryGirl.create(:template_ns, :name => 'ns2.%ZONE%', :zone_template => subject)
    FactoryGirl.create(:template_cname, :zone_template => subject)
    FactoryGirl.create(:template_cname, :name => 'www.%ZONE%', :zone_template => subject)

    @domain = subject.build( 'example.org', @user )
  end

  it "should create a valid new zone" do
    expect(@domain).to be_valid
    expect(@domain).to be_a_kind_of( Domain )
  end

  it "should be owned by the user" do
    expect(@domain.user).to be( @user )
  end

  it "should create the correct number of records (from templates)" do
    expect(@domain.records.size).to eql( subject.record_templates.size )
  end

  it "should create a SOA record" do
    soa = @domain.soa_record
    expect(soa).not_to be_nil
    expect(soa).to be_a_kind_of( SOA )
    expect(soa.primary_ns).to eql('ns1.example.org')
  end

  it "should create two NS records" do
    ns = @domain.ns_records
    expect(ns).to be_a_kind_of( Array )
    expect(ns.size).to be(2)

    ns.each { |r| expect(r).to be_a_kind_of( NS ) }
  end

  it "should create the correct CNAME's from the template" do
    cnames = @domain.cname_records
    expect(cnames.size).to be(2)
  end

end

describe ZoneTemplate, "and finders" do

  before(:each) do
    zt1 = FactoryGirl.create(:zone_template)
    FactoryGirl.create(:template_soa, :zone_template => zt1 )

    FactoryGirl.create(:zone_template, :name => 'No SOA')
  end

  it "should be able to return all templates" do
    expect(ZoneTemplate.find(:all).size).to be( ZoneTemplate.count )
  end

  it "should respect required validations" do
    expect(ZoneTemplate.find(:all, :require_soa => true).size).to be( 1 )
  end
end
