require 'spec_helper'

describe Domain do

  context "'untyped'" do
    it "should be NATIVE by default" do
      expect(subject.type).to eq('NATIVE')
    end

    it "should not accept rubbish types" do
      subject.type = 'DOMINANCE'
      subject.valid?
      expect( subject.errors[:type].size ).to eq(1)
    end
  end

  context "new MASTER/NATIVE" do
    it "should require a name" do
      subject.valid?
      expect( subject.errors[:name].size ).to eq(1)
    end

    it "should not allow duplicate names" do
      FactoryGirl.create(:domain)
      subject.name = "example.com"
      subject.valid?
      expect( subject.errors[:name].size ).to eq(1)
    end

    it "should bail out on missing SOA fields" do
      subject.valid?
      expect( subject.errors[:primary_ns].size ).to eq(1)
    end

    it "should be NATIVE by default" do
      expect(subject.type).to eql('NATIVE')
    end

    it "should not require a MASTER" do
      subject.valid?
      expect( subject.errors[:master].size ).to eq(0)
    end
  end

  context "new SLAVE" do
    subject { Domain.new( :type => 'SLAVE' ) }

    it "should require a master address" do
      subject.valid?
      expect( subject.errors[:master].size ).to eq(1)
    end

    it "should require a valid master address" do
      subject.master = 'foo'
      subject.valid?
      expect( subject.errors[:master].size ).to eq(1)

      subject.master = '127.0.0.1'
      subject.valid?
      expect( subject.errors[:master].size ).to eq(0)
    end

    it "should not bail out on missing SOA fields" do
      subject.valid?
      expect( subject.errors[:primary_ns].size ).to eq(0)
    end
  end

  context "existing" do
    subject { FactoryGirl.create(:domain) }

    it "should have a name" do
      expect(subject.name).to eql('example.com')
    end

    it "should have an SOA record" do
      expect(subject.soa_record).to be_a_kind_of( SOA )
    end

    it "should have NS records" do
      ns1 = FactoryGirl.create(:ns, :domain => subject)
      ns2 = FactoryGirl.create(:ns, :domain => subject)
      ns = subject.ns_records
      expect(ns).to be_a_kind_of( Array )
      expect(ns).to include( ns1 )
      expect(ns).to include( ns2 )
    end

    it "should have MX records" do
      mx_f = FactoryGirl.create(:mx, :domain => subject)
      mx = subject.mx_records
      expect(mx).to be_a_kind_of( Array )
      expect(mx).to include( mx_f )
    end

    it "should have A records" do
      a_f = FactoryGirl.create(:a, :domain => subject)
      a = subject.a_records
      expect(a).to be_a_kind_of( Array )
      expect(a).to include( a_f )
    end

    it "should give access to all records excluding the SOA" do
      FactoryGirl.create(:a, :domain => subject)
      expect(subject.records_without_soa.size).to be( subject.records.size - 1 )
    end

    it "should not complain about missing SOA fields" do
      subject.valid?
      expect( subject.errors[:primary_ns].size ).to eq(0)
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

      expect(Domain.user( admin ).all).to include(quentin_domain)
      expect(Domain.user( admin ).all).to include(aaron_domain)
    end

    it "should restrict owners" do
      quentin_domain
      aaron_domain

      expect(Domain.user( quentin ).all).to include(quentin_domain)
      expect(Domain.user( quentin ).all).not_to include(aaron_domain)

      expect(Domain.user( aaron ).all).not_to include(quentin_domain)
      expect(Domain.user( aaron ).all).to include(aaron_domain)
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

      expect(subject.save).to be_truthy
      expect(subject.soa_record).not_to be_nil
      expect(subject.soa_record.primary_ns).to eql('ns1.example.org')
    end
  end

  context "SLAVE when created" do
    subject { Domain.new( type: 'SLAVE' ) }

    it "should create with SOA requirements or SOA record" do
      subject.name = 'example.org'
      subject.master = '127.0.0.1'

      expect(subject.save).to be_truthy
      expect(subject.soa_record).to be_nil
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
      expect(Domain.search('exa', 1, FactoryGirl.create(:admin))).not_to be_empty
    end

    it "should return results for users" do
      expect(Domain.search('exa', 1, quentin)).not_to be_empty
    end

    it "should return unscoped results" do
      expect(Domain.search('exa', 1)).not_to be_empty
    end
  end
end
