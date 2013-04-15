require 'spec_helper'

describe Domain do

  context "'untyped'" do
    it "should be NATIVE by default" do
      subject.type.should == 'NATIVE'
    end

    it "should not accept rubbish types" do
      subject.type = 'DOMINANCE'
      subject.should have(1).error_on(:type)
    end
  end

  context "new MASTER/NATIVE" do
    it "should require a name" do
      subject.should have(1).error_on(:name)
    end

    it "should not allow duplicate names" do
      FactoryGirl.create(:domain)
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

  context "new SLAVE" do
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

  context "existing" do
    subject { FactoryGirl.create(:domain) }

    it "should have a name" do
      subject.name.should eql('example.com')
    end

    it "should have an SOA record" do
      subject.soa_record.should be_a_kind_of( SOA )
    end

    it "should have NS records" do
      ns1 = FactoryGirl.create(:ns, :domain => subject)
      ns2 = FactoryGirl.create(:ns, :domain => subject)
      ns = subject.ns_records
      ns.should be_a_kind_of( Array )
      ns.should include( ns1 )
      ns.should include( ns2 )
    end

    it "should have MX records" do
      mx_f = FactoryGirl.create(:mx, :domain => subject)
      mx = subject.mx_records
      mx.should be_a_kind_of( Array )
      mx.should include( mx_f )
    end

    it "should have A records" do
      a_f = FactoryGirl.create(:a, :domain => subject)
      a = subject.a_records
      a.should be_a_kind_of( Array )
      a.should include( a_f )
    end

    it "should give access to all records excluding the SOA" do
      FactoryGirl.create(:a, :domain => subject)
      subject.records_without_soa.size.should be( subject.records.size - 1 )
    end

    it "should not complain about missing SOA fields" do
      subject.should have(:no).errors_on(:primary_ns)
    end
  end

  context "scopes" do
    let(:quentin) { FactoryGirl.create(:quentin) }
    let(:aaron) { FactoryGirl.create(:aaron) }
    let(:quentin_domain) { FactoryGirl.create(:domain, :user => quentin) }
    let(:aaron_domain) { FactoryGirl.create(:domain, :name => 'example.org', :user => aaron) }
    let(:admin) { FactoryGirl.create(:admin) }

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

  context "NATIVE/MASTER when created" do
    it "with additional attributes should create an SOA record" do
      subject.name = 'example.org'
      subject.primary_ns = 'ns1.example.org'
      subject.contact = 'admin@example.org'
      subject.refresh = 10800
      subject.retry = 7200
      subject.expire = 604800
      subject.minimum = 10800

      subject.save.should be_true
      subject.soa_record.should_not be_nil
      subject.soa_record.primary_ns.should eql('ns1.example.org')
    end
  end

  context "SLAVE when created" do
    subject { Domain.new( type: 'SLAVE' ) }

    it "should create with SOA requirements or SOA record" do
      subject.name = 'example.org'
      subject.master = '127.0.0.1'

      subject.save.should be_true
      subject.soa_record.should be_nil
    end
  end

  context "deleting" do
    it "should delete its records as well" do
      domain = FactoryGirl.create(:domain)
      expect {
        domain.destroy
      }.to change(Record, :count).by(-domain.records.size)
    end
  end

  context "searching" do
    let(:quentin) { FactoryGirl.create(:quentin) }

    before(:each) do
      FactoryGirl.create(:domain, :user => quentin)
    end

    it "should return results for admins" do
      Domain.search('exa', 1, FactoryGirl.create(:admin)).should_not be_empty
    end

    it "should return results for users" do
      Domain.search('exa', 1, quentin).should_not be_empty
    end

    it "should return unscoped results" do
      Domain.search('exa', 1).should_not be_empty
    end
  end
end
