require 'spec_helper'

describe "domains/apply_macro.html.haml" do
  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @macro = FactoryGirl.create(:macro)

    assign(:domain, @domain)
    assign(:macros, Macro.all)

    render
  end

  it "should have a selection of macros" do
    rendered.should have_tag('select[name=macro_id]')
  end

end
