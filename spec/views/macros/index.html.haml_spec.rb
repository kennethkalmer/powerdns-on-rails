require 'spec_helper'

describe "macros/index.html.haml" do

  it "should render a list of macros" do
    2.times { |i| FactoryGirl.create(:macro, :name => "Macro #{i}") }
    assign(:macros, Macro.all)

    render

    expect(rendered).to have_tag('h1', :content => 'Macros')
    expect(render).to have_tag("table a[href^='/macro']")
  end

  it "should indicate no macros are present" do
    assign(:macros, Macro.all)

    render

    expect(rendered).to have_tag('em', :content => "don't have any macros")
  end

end
