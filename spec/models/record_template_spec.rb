require 'spec_helper'

describe RecordTemplate do
  context "when new" do

    it "should be invalid by default" do
      expect(subject).not_to be_valid
    end

  end

  describe "should inherit" do
    before(:each) do
      subject.zone_template = FactoryGirl.create(:zone_template)
    end

    it "validations from A" do
      subject.record_type = 'A'
      expect(subject).not_to be_valid

      subject.content = '256.256.256.256'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)

      subject.content = 'google.com'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)

      subject.content = '10.0.0.9'
      subject.valid?
      expect( subject.errors[:content].size ).to eq(0)
    end

    it "validations from CNAME" do
      subject.record_type = 'NS'
      expect(subject).not_to be_valid

      subject.valid?
      expect( subject.errors[:content].size ).to eq(2)
    end

    it "validations from MX" do
      subject.record_type = 'MX'
      expect(subject).not_to be_valid

      subject.valid?
      expect( subject.errors[:prio].size ).to eq(1)
      expect( subject.errors[:content].size ).to eq(2)

      subject.prio = -10
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(1)

      # FIXME: Why is priority 0 at this stage?
      #subject.prio = 'low'
      #subject.should have(1).error_on(:prio)

      subject.prio = 10
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(0)
    end

    it "validations from NS" do
      subject.record_type = 'NS'
      expect(subject).not_to be_valid

      subject.valid?
      expect( subject.errors[:content].size ).to eq(2)
    end

    it "validations from TXT" do
      subject.record_type = 'TXT'
      expect(subject).not_to be_valid

      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

    it "validations from SOA" do
      subject.record_type = 'SOA'
      expect(subject).not_to be_valid

      subject.valid?
      expect( subject.errors[:primary_ns].size ).to eq(1)
    end

    it "validates contact address in SOA" do
      subject.record_type = 'SOA'
      subject.valid?
      expect( subject.errors[:contact].size ).to eq(1)

      subject.contact = 'admin@example.com'
      subject.valid?
      expect( subject.errors[:contact].size ).to eq(0)

      subject.contact = 'admin@%ZONE%'
      subject.valid?
      expect( subject.errors[:contact].size ).to eq(0)

      subject.contact = 'admin'
      subject.valid?
      expect( subject.errors[:contact].size ).to eq(1)
    end

    it "convenience methods from SOA" do
      subject.record_type = 'SOA'

      subject.primary_ns = 'ns1.%ZONE%'
      subject.contact = 'admin@%ZONE%'
      subject.refresh = 7200
      subject.retry = 1800
      subject.expire = 604800
      subject.minimum = 10800

      expect(subject.content).to eql('ns1.%ZONE% admin@%ZONE% 0 7200 1800 604800 10800')
      expect(subject).to be_valid
      expect(subject.save).to be_truthy
    end
  end

  describe "when building" do

    before(:each) do
      @zone_template = FactoryGirl.create(:zone_template)
    end

    it "an SOA should replace the %ZONE% token with the provided domain name" do
      template = FactoryGirl.create(:template_soa, :zone_template => @zone_template)
      record = template.build( 'example.org' )

      expect(record).not_to be_nil
      expect(record).to be_a_kind_of( SOA )
      expect(record.primary_ns).to eq('ns1.example.org')
      expect(record.contact).to eq('admin@example.org')
    end

    it "an NS should replace the %ZONE% token with the provided domain name" do
      template = FactoryGirl.create(:template_ns, :zone_template => @zone_template)
      record = template.build( 'example.org' )

      expect(record).not_to be_nil
      expect(record).to be_a_kind_of( NS )
      expect(record.content).to eql('ns1.example.org')
    end

    it "a MX should replace the %ZONE% token with provided domain name" do
      template = FactoryGirl.create(:template_mx, :zone_template => @zone_template)
      record = template.build( 'example.org' )

      expect(record).not_to be_nil
      expect(record).to be_a_kind_of( MX )
      expect(record.content).to eql('mail.example.org')
    end
  end

  context "when creating" do
    before(:each) do
      @zone_template = FactoryGirl.create(:zone_template)
    end

    it "should inherit the TTL from the ZoneTemplate" do
      record_template = RecordTemplate.new( :zone_template => @zone_template )
      record_template.record_type = 'A'
      record_template.content = '10.0.0.1'
      expect(record_template.save).to be_truthy

      expect(record_template.ttl).to be(@zone_template.ttl)
    end

    it "should prefer own TTL over that of the ZoneTemplate" do
      record_template = RecordTemplate.new( :zone_template => @zone_template )
      record_template.record_type = 'A'
      record_template.content = '10.0.0.1'
      record_template.ttl = 43200
      expect(record_template.save).to be_truthy

      expect(record_template.ttl).to be(43200)
    end
  end

  context "when loaded" do
    it "should have SOA convenience, if an SOA template" do
      zone_template = FactoryGirl.create(:zone_template)
      record_template = FactoryGirl.create(:template_soa, :zone_template => zone_template)
      expect(record_template.primary_ns).to eql('ns1.%ZONE%')
      expect(record_template.retry).to be(7200)
    end
  end

  context "when updated" do
    it "should handle SOA convenience" do
      zone_template = FactoryGirl.create(:zone_template)
      record_template = FactoryGirl.create(:template_soa, :zone_template => zone_template, :primary_ns => 'ns1.provider.net')
      record_template.primary_ns = 'ns1.provider.net'

      record_template.save
      record_template.reload

      expect(record_template.primary_ns).to eql('ns1.provider.net')
    end
  end
end
