require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Macro, "when new" do
  before(:each) do
    @macro = Macro.new
  end

  it "should require a new" do
    @macro.should have(1).error_on(:name)
  end

  it "should have a unique name" do
    m = Factory(:macro)
    @macro.name = m.name
    @macro.should have(1).error_on(:name)
  end

  it "should be disabled by default" do
    @macro.should_not be_active
  end

end

describe Macro, "when applied" do
  before(:each) do
    @target = Factory(:domain)

    @macro = Factory(:macro)
    @step_create = Factory(:macro_step_create, :macro => @macro, :name => 'foo')
    @step_update = Factory(:macro_step_change, :macro => @macro, :record_type => 'A', :name => 'www', :content => '127.0.0.9')
    @step_remove_target = Factory(:macro_step_remove, :macro => @macro, :record_type => 'A', :name => 'mail')
    @step_remove_wild = Factory(:macro_step_remove, :macro => @macro, :record_type => 'MX', :name => '*')

    @step_update2 = Factory(:macro_step_change, :macro => @macro, :record_type => 'A', :name => 'admin', :content => '127.0.0.10')
  end

  it "should create new RR's" do
    @macro.apply_to( @target )
    @target.a_records.map(&:shortname).should include('foo')
  end

  it "should update existing RR's" do
    rr = Factory(:www, :domain => @target)

    lambda {
      @macro.apply_to( @target )
      rr.reload
    }.should change( rr, :content )
  end

  it "should remove targetted RR's" do
    rr = Factory(:a, :name => 'mail', :domain => @target)

    @macro.apply_to( @target )

    lambda { rr.reload }.should raise_error( ActiveRecord::RecordNotFound )
  end

  it "should remove existing RR's (wild card)" do
    Factory(:mx, :domain => @target)
    @target.mx_records(true).should_not be_empty

    @macro.apply_to( @target )

    @target.mx_records(true).should be_empty
  end

  it "should not create RR's that were supposed to be updated but doesn't exist" do
    @macro.apply_to( @target )

    @target.reload.a_records.detect { |a| a.name =~ /^admin/ }.should be_nil
  end
end

