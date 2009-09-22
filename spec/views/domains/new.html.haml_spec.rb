require File.dirname(__FILE__) + '/../../spec_helper'

describe "domains/new.html.haml" do

  before(:each) do
    assigns[:domain] = Domain.new
  end

  it "should have a link to create a zone template if no zone templates are present" do
    assigns[:zone_templates] = []

    render "domains/new.html.haml"

    response.should have_tag("a[href=#{new_zone_template_path}]", "Create Zone Templates")
    response.should_not have_tag("select[name*=zone_template_id]")
  end

  it "should have a list of zone templates to select from" do
    assigns[:zone_templates] = [ Factory(:zone_template) ]

    render "domains/new.html.haml"

    response.should have_tag("select[name*=zone_template_id]")
    response.should_not have_tag("a[href=#{new_zone_template_path}]")
  end

end
