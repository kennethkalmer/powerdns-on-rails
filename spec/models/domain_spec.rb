require 'spec_helper'

describe "New 'untyped'", Domain do
  subject { Domain.new }

  it "should be NATIVE by default" do
    subject.type.should == 'NATIVE'
  end

  it "should not accept rubbish types" do
    subject.type = 'DOMINANCE'
    subject.should have(1).error_on(:type)
  end
end

describe "New MASTER/NATIVE", Domain do
  subject { Domain.new }

  it "should require a name" do
    subject.should have(1).error_on(:name)
  end

  it "should not allow duplicate names" do
    Factory(:domain)
    subject.name = "example.com"
    subject.should have(1).error_on(:name)
  end

  it "should bail out on missing SOA fields" do
    subject.should have(1).error_on( :primary_ns )
  end

  it "should be NATIVE by default" do
    subject.type.should eql('NATIVE')
  end

  it "should not require a MASTER" do
    subject.should have(:no).errors_on(:master)
  end
end

describe "New SLAVE", Domain do
  subject { Domain.new( :type => 'SLAVE' ) }

  it "should require a master address" do
    subject.should have(1).error_on(:master)
  end

  it "should require a valid master address" do
    subject.master = 'foo'
    subject.should have(1).error_on(:master)

    subject.master = '127.0.0.1'
    subject.should have(:no).errors_on(:master)
  end

  it "should not bail out on missing SOA fields" do
    subject.should have(:no).errors_on( :primary_ns )
  end
end

describe Domain, "when loaded" do
  before(:each) do
    @domain = Factory(:domain)
  end

  it "should have a name" do
    @domain.name.should eql('example.com')
  end

  it "should have an SOA record" do
    @domain.soa_record.should be_a_kind_of( SOA )
  end

  it "should have NS records" do
    ns1 = Factory(:ns, :domain => @domain)
    ns2 = Factory(:ns, :domain => @domain)
    ns = @domain.ns_records
    ns.should be_a_kind_of( Array )
    ns.should include( ns1 )
    ns.should include( ns2 )
  end

  it "should have MX records" do
    mx_f = Factory(:mx, :domain => @domain)
    mx = @domain.mx_records
    mx.should be_a_kind_of( Array )
    mx.should include( mx_f )
  end

  it "should have A records" do
    a_f = Factory(:a, :domain => @domain)
    a = @domain.a_records
    a.should be_a_kind_of( Array )
    a.should include( a_f )
  end

  it "should give access to all records excluding the SOA" do
    Factory(:a, :domain => @domain)
    @domain.records_without_soa.size.should be( @domain.records.size - 1 )
  end

  it "should not complain about missing SOA fields" do
    @domain.should have(:no).errors_on(:primary_ns)
  end
end

describe Domain, "scopes" do
  let(:quentin) { Factory(:quentin) }
  let(:aaron) { Factory(:aaron) }
  let(:quentin_domain) { Factory(:domain, :user => quentin) }
  let(:aaron_domain) { Factory(:domain, :name => 'example.org', :user => aaron) }
  let(:admin) { Factory(:admin) }

  it "should show all domains to an admin" do
    quentin_domain
    aaron_domain

    Domain.user( admin ).all.should include(quentin_domain)
    Domain.user( admin ).all.should include(aaron_domain)
  end

  it "should restrict owners" do
    quentin_domain
    aaron_domain

    Domain.user( quentin ).all.should include(quentin_domain)
    Domain.user( quentin ).all.should_not include(aaron_domain)

    Domain.user( aaron ).all.should_not include(quentin_domain)
    Domain.user( aaron ).all.should include(aaron_domain)
  end

  it "should restrict authentication tokens"
end

describe "NATIVE/MASTER", Domain, "when created" do
  it "with additional attributes should create an SOA record" do
    domain = Domain.new
    domain.name = 'example.org'
    domain.primary_ns = 'ns1.example.org'
    domain.contact = 'admin@example.org'
    domain.refresh = 10800
    domain.retry = 7200
    domain.expire = 604800
    domain.minimum = 10800

    domain.save.should be_true
    domain.soa_record.should_not be_nil
    domain.soa_record.primary_ns.should eql('ns1.example.org')
  end

  it "with bulk additional attributes should be acceptable" do
    domain = Domain.new(
      :name => 'example.org',
      :primary_ns => 'ns1.example.org',
      :contact => 'admin@example.org',
      :refresh => 10800,
      :retry => 7200,
      :expire => 608400,
      :minimum => 10800
    )

    domain.save.should be_true
    domain.soa_record.should_not be_nil
    domain.soa_record.primary_ns.should eql('ns1.example.org')
  end
end

describe "SLAVE", Domain, "when created" do
  before(:each) do
    @domain = Domain.new( :type => 'SLAVE' )
  end

  it "should create with SOA requirements or SOA record" do
    @domain.name = 'example.org'
    @domain.master = '127.0.0.1'

    @domain.save.should be_true
    @domain.soa_record.should be_nil
  end
end

describe Domain, "when deleting" do
  it "should delete its records as well" do
    domain = Factory(:domain)
    expect {
      domain.destroy
    }.to change(Record, :count).by(-domain.records.size)
  end
end

describe Domain, "when searching" do
  before(:each) do
    @quentin = Factory(:quentin)
    Factory(:domain, :user => @quentin)
  end

  it "should return results for admins" do
    Domain.search('exa', 1, Factory(:admin)).should_not be_empty
  end

  it "should return results for users" do
    Domain.search('exa', 1, @quentin).should_not be_empty
  end

  it "should return unscoped results" do
    Domain.search('exa', 1).should_not be_empty
  end
end
