require File.dirname(__FILE__) + '/../spec_helper'

describe Record, "when new" do
  before(:each) do
    @record = Record.new
  end

  it "should be invalid by default" do
    @record.should_not be_valid
  end

  it "should require a domain" do
    @record.should have(1).error_on(:domain_id)
  end

  it "should require a ttl" do
    @record.should have(1).error_on(:ttl)
  end

  it "should only allow positive numeric ttl's" do
    @record.ttl = -100
    @record.should have(1).error_on(:ttl)

    @record.ttl = '2d'
    @record.should have(1).error_on(:ttl)

    @record.ttl = 86400
    @record.should have(:no).errors_on(:ttl)
  end

  it "should require a name" do
    @record.should have(1).error_on(:name)
  end

  it "should not support priorities by default" do
    @record.supports_prio?.should be_false
  end

end

describe Record, "during updates" do
  before(:each) do
    @domain = Factory(:domain)
    @soa = @domain.soa_record
  end

  it "should update the serial on the SOA" do
    serial = @soa.serial

    record = Factory(:a, :domain => @domain)
    record.content = '10.0.0.1'
    record.save.should be_true

    @soa.reload
    @soa.serial.should_not eql( serial )
  end

  it "should be able to restrict the serial number to one change (multiple updates)" do
    serial = @soa.serial

    # Implement some cheap DNS load balancing
    Record.batch do

      record = A.new(
        :domain => @domain,
        :name => 'app',
        :content => '10.0.0.5',
        :ttl => 86400
      )
      record.save.should be_true

      record = A.new(
        :domain => @domain,
        :name => 'app',
        :content => '10.0.0.6',
        :ttl => 86400
      )
      record.save.should be_true

      record = A.new(
        :domain => @domain,
        :name => 'app',
        :content => '10.0.0.7',
        :ttl => 86400
      )
      record.save.should be_true
    end

    # Our serial should have move just one position, not three
    @soa.reload
    @soa.serial.should_not be( serial )
    @soa.serial.to_s.should eql( Time.now.strftime( "%Y%m%d" ) + '01' )
  end

end

describe Record, "when created" do
  before(:each) do
    @domain = Factory(:domain)
    @soa = @domain.soa_record
  end

  it "should update the serial on the SOA" do
    serial = @soa.serial

    record = A.new(
      :domain => @domain,
      :name => 'admin',
      :content => '10.0.0.5',
      :ttl => 86400
    )
    record.save.should be_true

    @soa.reload
    @soa.serial.should_not eql(serial)
  end

  it "should inherit the name from the parent domain if not provided" do
    record = A.new(
      :domain => @domain,
      :content => '10.0.0.6'
    )
    record.save.should be_true

    record.name.should eql('example.com')
  end

  it "should append the domain name to the name if not present" do
    record = A.new(
      :domain => @domain,
      :name => 'test',
      :content => '10.0.0.6'
    )
    record.save.should be_true

    record.shortname.should eql('test')
    record.name.should eql('test.example.com')
  end

  it "should inherit the TTL from the parent domain if not provided" do
    ttl = @domain.ttl
    ttl.should be( 86400 )

    record = A.new(
      :domain => @domain,
      :name => 'ftp',
      :content => '10.0.0.6'
    )
    record.save.should be_true

    record.ttl.should be( 86400 )
  end

  it "should prefer own TTL over that of parent domain" do
    record = A.new(
      :domain => @domain,
      :name => 'ftp',
      :content => '10.0.0.6',
      :ttl => 43200
    )
    record.save.should be_true

    record.ttl.should be( 43200 )
  end

end

describe Record, "when loaded" do
  before(:each) do
    domain = Factory(:domain)
    @record = Factory(:a, :domain => domain)
  end

  it "should have a full name" do
    @record.name.should eql('example.com')
  end

  it "should have a short name" do
    @record.shortname.should be_blank
  end
end

describe Record, "when serializing to XML" do
  before(:each) do
    domain = Factory(:domain)
    @record = Factory(:a, :domain => domain)
  end

  it "should have a root tag of the record type" do
    @record.to_xml.should match(/<a>/)
  end

end
