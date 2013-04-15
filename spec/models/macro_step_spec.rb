require 'spec_helper'

describe MacroStep do
  context "when new" do

    it "should be invalid by default" do
      subject.should_not be_valid
    end

    it "should require a macro" do
      subject.should have(1).error_on(:macro_id)
    end

    it "should require an action" do
      subject.should have(1).error_on(:action)
    end

    it "should only accept allowed actions" do
      [ 'create', 'remove', 'update' ].each do |valid_action|
        subject.action = valid_action
        subject.should have(:no).errors_on(:action)
      end

      subject.action = 'foo'
      subject.should have(1).error_on(:action)
    end

    it "should require a record type" do
      subject.should have(1).error_on(:record_type)
    end

    it "should only accept valid record types" do
      Record.record_types.each do |known_record_type|
        # We don't apply macro's to SOA records
        next if known_record_type == 'SOA'

        subject.record_type = known_record_type
        subject.should have(:no).errors_on(:record_type)
      end

      subject.record_type = 'SOA'
      subject.should have(1).error_on(:record_type)
    end

    it "should not require a record name" do
      subject.should have(:no).errors_on(:name)
    end

    it "should require content" do
      subject.should have(1).error_on(:content)
    end

    it "should be active by default" do
      subject.should be_active
    end

    describe "should inherit validations" do
      it "from A records" do
        subject.record_type = 'A'
        subject.content = 'foo'
        subject.should have(1).error_on(:content)
        subject.should have(:no).errors_on(:name)
      end

      it "from MX records" do
        subject.record_type = 'MX'
        subject.should have(1).error_on(:prio)
        subject.should have(:no).errors_on(:name)
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
      @macro_step.position.should_not be_blank
    end
  end

  context "for removing records" do
    before(:each) do
      subject.action = 'remove'
    end

    it "should not require content" do
      subject.should have(:no).errors_on(:content)
    end

    it "should not require prio on MX" do
      subject.record_type = 'MX'
      subject.should have(:no).errors_on(:prio)
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
      record.should be_an_instance_of( A )
    end

  end
end

