require File.dirname(__FILE__) + '/../../spec_helper'

describe "domains/apply_macro.html.haml" do
  before(:each) do
    @domain = Factory(:domain)
    @macro = Factory(:macro)

    assigns[:domain] = @domain
    assigns[:macros] = Macro.find(:all)

    render "domains/apply_macro.html.haml"
  end

  it "should have a selection of macros" do
    response.should have_tag('select[name=macro_id]')
  end

end
