require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MacroStep, "when new" do
  before(:each) do
    @macro_step = MacroStep.new
  end

  it "should be invalid by default" do
    @macro_step.should_not be_valid
  end

  it "should require a macro" do
    @macro_step.should have(1).error_on(:macro_id)
  end

  it "should require an action" do
    @macro_step.should have(1).error_on(:action)
  end

  it "should only accept allowed actions" do
    [ 'create', 'remove', 'update' ].each do |valid_action|
      @macro_step.action = valid_action
      @macro_step.should have(:no).errors_on(:action)
    end

    @macro_step.action = 'foo'
    @macro_step.should have(1).error_on(:action)
  end

  it "should require a record type" do
    @macro_step.should have(1).error_on(:record_type)
  end

  it "should only accept valid record types" do
    Record.record_types.each do |known_record_type|
      # We don't apply macro's to SOA records
      next if known_record_type == 'SOA'

      @macro_step.record_type = known_record_type
      @macro_step.should have(:no).errors_on(:record_type)
    end

    @macro_step.record_type = 'SOA'
    @macro_step.should have(1).error_on(:record_type)
  end

  it "should not require a record name" do
    @macro_step.should have(:no).errors_on(:name)
  end

  it "should require content" do
    @macro_step.should have(1).error_on(:content)
  end

  it "should be active by default" do
    @macro_step.should be_active
  end

  describe "should inherit validations" do
    it "from A records" do
      @macro_step.record_type = 'A'
      @macro_step.content = 'foo'
      @macro_step.should have(1).error_on(:content)
      @macro_step.should have(:no).errors_on(:name)
    end

    it "from MX records" do
      @macro_step.record_type = 'MX'
      @macro_step.should have(1).error_on(:prio)
      @macro_step.should have(:no).errors_on(:name)
    end

  end

end

describe MacroStep, "when created" do
  before(:each) do
    @macro = Factory(:macro)
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

describe MacroStep, "for removing records" do
  before(:each) do
    @macro_step = MacroStep.new
    @macro_step.action = 'remove'
  end

  it "should not require content" do
    @macro_step.should have(:no).errors_on(:content)
  end

  it "should not require prio on MX" do
    @macro_step.record_type = 'MX'
    @macro_step.should have(:no).errors_on(:prio)
  end

end


describe MacroStep, "when building records" do
  before(:each) do
    @macro_step = MacroStep.new
  end

  it "should build A records" do
    @macro_step.attributes = {
      :record_type => 'A',
      :name => 'www',
      :content => '127.0.0.7'
    }

    record = @macro_step.build
    record.should be_an_instance_of( A )
  end

end

