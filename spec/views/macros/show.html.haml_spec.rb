require 'spec_helper'

describe "macros/show.html.haml" do
  before(:each) do
    @macro = Factory(:macro)
    Factory(:macro_step_create, :macro => @macro)

    assign(:macro, @macro)
    assign(:macro_step, @macro.macro_steps.new)

    render
  end

  it "should have the name of the macro" do
    rendered.should have_tag('h1', :content => @macro.name)
  end

  it "should have an overview table" do
    rendered.should have_tag('table.grid td', :content => "Name")
    rendered.should have_tag('table.grid td', :content => "Description")
    rendered.should have_tag('table.grid td', :content => "Active")
  end

  it "should have a list of steps" do
    rendered.should have_tag('h1', :content => 'Macro Steps')
    rendered.should have_tag('table#steps-table td', :content => "1")
  end

end
