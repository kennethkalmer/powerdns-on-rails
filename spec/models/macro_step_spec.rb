require 'spec_helper'

describe MacroStep do
  context "when new" do

    it "should be invalid by default" do
      expect(subject).not_to be_valid
    end

    it "should require a macro" do
      subject.valid?
      expect( subject.errors[:macro_id].size ).to eq(1)
    end

    it "should require an action" do
      subject.valid?
      expect( subject.errors[:action].size ).to eq(1)
    end

    it "should only accept allowed actions" do
      [ 'create', 'remove', 'update' ].each do |valid_action|
        subject.action = valid_action
        subject.valid?
        expect( subject.errors[:action].size ).to eq(0)
      end

      subject.action = 'foo'
      subject.valid?
      expect( subject.errors[:action].size ).to eq(1)
    end

    it "should require a record type" do
      subject.valid?
      expect( subject.errors[:record_type].size ).to eq(1)
    end

    it "should only accept valid record types" do
      Record.record_types.each do |known_record_type|
        # We don't apply macro's to SOA records
        next if known_record_type == 'SOA'

        subject.record_type = known_record_type
        subject.valid?
        expect( subject.errors[:record_type].size ).to eq(0)
      end

      subject.record_type = 'SOA'
      subject.valid?
      expect( subject.errors[:record_type].size ).to eq(1)
    end

    it "should not require a record name" do
      subject.valid?
      expect( subject.errors[:name].size ).to eq(0)
    end

    it "should require content" do
      subject.valid?
      expect( subject.errors[:content].size ).to eq(1)
    end

    it "should be active by default" do
      expect(subject).to be_active
    end

    describe "should inherit validations" do
      it "from A records" do
        subject.record_type = 'A'
        subject.content = 'foo'

        subject.valid?
        expect( subject.errors[:content].size ).to eq(1)
        expect( subject.errors[:name].size ).to eq(0)
      end

      it "from MX records" do
        subject.record_type = 'MX'
        subject.valid?

        expect( subject.errors[:prio].size ).to eq(1)
        expect( subject.errors[:name].size ).to eq(0)
      end

    end

  end

  context "when created" do
    before(:each) do
      @macro = FactoryGirl.create(:macro)
      @macro_step = MacroStep.create!(
        :macro => @macro,
        :record_type => 'A',
        :action => 'create',
        :name => 'cdn',
        :content => '127.0.0.8',
        :ttl => 86400
        )
    end

    it "should have a position" do
      expect(@macro_step.position).not_to be_blank
    end
  end

  context "for removing records" do
    before(:each) do
      subject.action = 'remove'
    end

    it "should not require content" do
      subject.valid?
      expect( subject.errors[:content].size ).to eq(0)
    end

    it "should not require prio on MX" do
      subject.record_type = 'MX'
      subject.valid?
      expect( subject.errors[:prio].size ).to eq(0)
    end

  end

  context "building records" do
    it "should build A records" do
      subject.attributes = {
        :record_type => 'A',
        :name => 'www',
        :content => '127.0.0.7'
      }

      record = subject.build
      expect(record).to be_an_instance_of( A )
    end

  end
end

