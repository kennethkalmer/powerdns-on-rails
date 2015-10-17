require 'spec_helper'

describe Record do
  let(:domain) { FactoryGirl.create(:domain) }

  context "when new" do

    it "should be invalid by default" do
      expect(subject).not_to be_valid
    end

    it "should require a domain" do
      subject.valid?
      expect( subject.errors[:domain_id].size ).to eq(1)
    end

    it "should require a ttl" do
      subject.valid?
      expect( subject.errors[:ttl].size ).to eq(1)
    end

    it "should only allow positive numeric ttl's" do
      subject.ttl = -100
      subject.valid?
      expect( subject.errors[:ttl].size ).to eq(1)

      subject.ttl = '2d'
      subject.valid?
      expect( subject.errors[:ttl].size ).to eq(1)

      subject.ttl = 86400
      subject.valid?
      expect( subject.errors[:ttl].size ).to eq(0)
    end

    it "should require a name" do
      subject.valid?
      expect( subject.errors[:name].size ).to eq(1)
    end

    it "should not support priorities by default" do
      expect(subject.supports_prio?).to be false
    end

  end

  describe "updates" do
    before(:each) do
      @soa = domain.soa_record
    end

    it "should update the serial on the SOA on create" do
      serial = @soa.serial

      record = FactoryGirl.create(:a, :domain => domain)

      expect(@soa.tap(&:reload).serial).not_to eql( serial )
    end

    it "should update the serial on the SOA on change" do
      record = FactoryGirl.create(:a, :domain => domain)
      serial = @soa.tap(&:reload).serial
      record.content = '10.0.0.1'
      expect(record.save).to be true

      expect(@soa.tap(&:reload).serial).not_to eql( serial )
    end

    it "should update the serial on the SOA when deleted" do
      record = FactoryGirl.create(:a, :domain => domain)

      serial = @soa.tap(&:reload).serial

      record.destroy
      expect( record.destroyed? ).to be true

      expect(@soa.tap(&:reload).serial).not_to eql( serial )
    end

    it "should be able to restrict the serial number to one change (multiple updates)" do
      serial = @soa.serial

      # Implement some cheap DNS load balancing
      Record.batch do

        record = A.new(
          :domain => domain,
          :name => 'app',
          :content => '10.0.0.5',
          :ttl => 86400
        )
        expect(record.save).to be true

        record = A.new(
          :domain => domain,
          :name => 'app',
          :content => '10.0.0.6',
          :ttl => 86400
        )
        expect(record.save).to be true

        record = A.new(
          :domain => domain,
          :name => 'app',
          :content => '10.0.0.7',
          :ttl => 86400
        )
        expect(record.save).to be true
      end

      # Our serial should have move just one position, not three
      @soa.reload
      expect(@soa.serial).not_to be( serial )
      expect(@soa.serial.to_s).to eql( Time.now.strftime( "%Y%m%d" ) + '01' )
    end

  end

  describe "when created" do
    before(:each) do
      @soa = domain.soa_record
    end

    it "should update the serial on the SOA" do
      serial = @soa.serial

      record = A.new(
        :domain => domain,
        :name => 'admin',
        :content => '10.0.0.5',
        :ttl => 86400
      )
      expect(record.save).to be true

      @soa.reload
      expect(@soa.serial).not_to eql(serial)
    end

    it "should inherit the name from the parent domain if not provided" do
      record = A.new(
        :domain => domain,
        :content => '10.0.0.6'
      )
      expect(record.save).to be true

      expect(record.name).to eql('example.com')
    end

    it "should append the domain name to the name if not present" do
      record = A.new(
        :domain => domain,
        :name => 'test',
        :content => '10.0.0.6'
      )
      expect(record.save).to be true

      expect(record.shortname).to eql('test')
      expect(record.name).to eql('test.example.com')
    end

    it "should inherit the TTL from the parent domain if not provided" do
      ttl = domain.ttl
      expect(ttl).to be( 86400 )

      record = A.new(
        :domain => domain,
        :name => 'ftp',
        :content => '10.0.0.6'
      )
      expect(record.save).to be true

      expect(record.ttl).to be( 86400 )
    end

    it "should prefer own TTL over that of parent domain" do
      record = A.new(
        :domain => domain,
        :name => 'ftp',
        :content => '10.0.0.6',
        :ttl => 43200
      )
      expect(record.save).to be true

      expect(record.ttl).to be( 43200 )
    end

  end

  describe "when loaded" do
    subject { FactoryGirl.create(:a, :domain => domain) }

    it "should have a full name" do
      expect(subject.name).to eql('example.com')
    end

    it "should have a short name" do
      expect(subject.shortname).to be_blank
    end
  end

  describe Record, "when serializing to XML" do
    subject { FactoryGirl.create(:a, :domain => domain) }

    it "should have a root tag of the record type" do
      expect(subject.to_xml).to match(/<a>/)
    end
  end

end
