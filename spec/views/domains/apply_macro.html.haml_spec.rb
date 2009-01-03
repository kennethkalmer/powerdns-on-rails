require File.dirname(__FILE__) + '/../../spec_helper'

describe "domains/apply_macro.html.haml" do
  fixtures :all
  
  before(:each) do
    @domain = domains(:example_com)
    @macro = Factory(:macro)

    assigns[:domain] = @domain
    assigns[:macros] = Macro.find(:all)

    render "domains/apply_macro.html.haml"
  end

  it "should have a selection of macros" do
    response.should have_tag('select[name=macro_id]')
  end
  
end
