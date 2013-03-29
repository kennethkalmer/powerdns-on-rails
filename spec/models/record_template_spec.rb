require 'spec_helper'

describe RecordTemplate do
  context "when new" do

    it "should be invalid by default" do
      subject.should_not be_valid
    end

  end

  describe "should inherit" do
    before(:each) do
      subject.zone_template = FactoryGirl.create(:zone_template)
    end

    it "validations from A" do
      subject.record_type = 'A'
      subject.should_not be_valid

      subject.content = '256.256.256.256'
      subject.should have(1).error_on(:content)

      subject.content = 'google.com'
      subject.should have(1).error_on(:content)

      subject.content = '10.0.0.9'
      subject.should have(:no).error_on(:content)
    end

    it "validations from CNAME" do
      subject.record_type = 'NS'
      subject.should_not be_valid

      subject.should have(2).error_on(:content)
    end

    it "validations from MX" do
      subject.record_type = 'MX'
      subject.should_not be_valid

      subject.should have(1).error_on(:prio)
      subject.should have(2).error_on(:content)

      subject.prio = -10
      subject.should have(1).error_on(:prio)

      # FIXME: Why is priority 0 at this stage?
      #subject.prio = 'low'
      #subject.should have(1).error_on(:prio)

      subject.prio = 10
      subject.should have(:no).errors_on(:prio)
    end

    it "validations from NS" do
      subject.record_type = 'NS'
      subject.should_not be_valid

      subject.should have(2).error_on(:content)
    end

    it "validations from TXT" do
      subject.record_type = 'TXT'
      subject.should_not be_valid

      subject.should have(1).error_on(:content)
    end

    it "validations from SOA" do
      subject.record_type = 'SOA'
      subject.should_not be_valid

      subject.should have(1).error_on(:primary_ns)
    end

    it "validates contact address in SOA" do
      subject.record_type = 'SOA'
      subject.should have(1).error_on(:contact)

      subject.contact = 'admin@example.com'
      subject.should have(:no).errors_on(:contact)

      subject.contact = 'admin@%ZONE%'
      subject.should have(:no).errors_on(:contact)

      subject.contact = 'admin'
      subject.should have(1).error_on(:contact)
    end

    it "convenience methods from SOA" do
      subject.record_type = 'SOA'

      subject.primary_ns = 'ns1.%ZONE%'
      subject.contact = 'admin@%ZONE%'
      subject.refresh = 7200
      subject.retry = 1800
      subject.expire = 604800
      subject.minimum = 10800

      subject.content.should eql('ns1.%ZONE% admin@%ZONE% 0 7200 1800 604800 10800')
      subject.should be_valid
      subject.save.should be_true
    end
  end

  describe "when building" do

    before(:each) do
      @zone_template = FactoryGirl.create(:zone_template)
    end

    it "an SOA should replace the %ZONE% token with the provided domain name" do
      template = FactoryGirl.create(:template_soa, :zone_template => @zone_template)
      record = template.build( 'example.org' )

      record.should_not be_nil
      record.should be_a_kind_of( SOA )
      record.primary_ns.should == 'ns1.example.org'
      record.contact.should == 'admin@example.org'
    end

    it "an NS should replace the %ZONE% token with the provided domain name" do
      template = FactoryGirl.create(:template_ns, :zone_template => @zone_template)
      record = template.build( 'example.org' )

      record.should_not be_nil
      record.should be_a_kind_of( NS )
      record.content.should eql('ns1.example.org')
    end

    it "a MX should replace the %ZONE% token with provided domain name" do
      template = FactoryGirl.create(:template_mx, :zone_template => @zone_template)
      record = template.build( 'example.org' )

      record.should_not be_nil
      record.should be_a_kind_of( MX )
      record.content.should eql('mail.example.org')
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
      record_template.save.should be_true

      record_template.ttl.should be(@zone_template.ttl)
    end

    it "should prefer own TTL over that of the ZoneTemplate" do
      record_template = RecordTemplate.new( :zone_template => @zone_template )
      record_template.record_type = 'A'
      record_template.content = '10.0.0.1'
      record_template.ttl = 43200
      record_template.save.should be_true

      record_template.ttl.should be(43200)
    end
  end

  context "when loaded" do
    it "should have SOA convenience, if an SOA template" do
      zone_template = FactoryGirl.create(:zone_template)
      record_template = FactoryGirl.create(:template_soa, :zone_template => zone_template)
      record_template.primary_ns.should eql('ns1.%ZONE%')
      record_template.retry.should be(7200)
    end
  end

  context "when updated" do
    it "should handle SOA convenience" do
      zone_template = FactoryGirl.create(:zone_template)
      record_template = FactoryGirl.create(:template_soa, :zone_template => zone_template, :primary_ns => 'ns1.provider.net')
      record_template.primary_ns = 'ns1.provider.net'

      record_template.save
      record_template.reload

      record_template.primary_ns.should eql('ns1.provider.net')
    end
  end
end
