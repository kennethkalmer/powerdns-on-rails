require File.dirname(__FILE__) + '/../../spec_helper'

describe "macros/show.html.haml" do
  before(:each) do
    @macro = Factory(:macro)
    Factory(:macro_step_create, :macro => @macro)

    assigns[:macro] = @macro
    assigns[:macro_step] = @macro.macro_steps.new

    render "macros/show.html.haml"
  end

  it "should have the name of the macro" do
    response.should have_tag('h1', /^#{@macro.name}/)
  end
  
  it "should have an overview table" do
    response.should have_tag('table.grid') do
      with_tag('td', 'Name')
      with_tag('td', 'Description')
      with_tag('td', 'Active')
    end
  end
  
  it "should have a list of steps" do
    response.should have_tag('h1', 'Macro Steps')
    response.should have_tag('table#steps-table') do
      with_tag 'td', '1'
    end
  end
    
end
