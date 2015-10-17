require 'spec_helper'

describe "domains/new.html.haml" do

  before(:each) do
    assign(:domain, Domain.new)

    view.stubs(:current_user).returns( FactoryGirl.create(:admin) )
  end

  it "should have a link to create a zone template if no zone templates are present" do
    assign(:zone_templates, [])

    render

    expect(rendered).to have_selector("a[href='#{new_zone_template_path}']")
    expect(rendered).not_to have_selector("select[name*=zone_template_id]")
  end

  it "should have a list of zone templates to select from" do
    zt = FactoryGirl.create(:zone_template)
    FactoryGirl.create(:template_soa, :zone_template => zt)

    render

    expect(rendered).to have_selector("select[name*=zone_template_id]")
    expect(rendered).not_to have_selector("a[href='#{new_zone_template_path}']")
  end

end
