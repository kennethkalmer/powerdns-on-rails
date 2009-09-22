require File.dirname(__FILE__) + '/../../spec_helper'

describe "/templates/form and new templates" do

  before(:each) do
    assigns[:zone_template] = ZoneTemplate.new
  end

  it "should have a list of users if provided" do
    u = User.new( :login => 'test' )
    u.id = 1

    assigns[:users] = [ u ]

    render "/templates/form"

    response.should have_tag('select#zone_template_user_id')
  end

  it "should render without a list of users" do
    assigns[:users] = []

    render "/templates/form"

    response.should_not have_tag('select#zone_template_user_id')
  end

  it "should render with a missing list of users (nil)" do
    render "/templates/form"

    response.should_not have_tag('select#zone_template_user_id')
  end

  it "should show the correct title" do
    render "/templates/form"

    response.should have_tag('h1.underline', 'New Zone Template')
  end
end

describe "/templates/form and existing templates" do

  before(:each) do
    @zone_template = Factory(:zone_template)
    assigns[:zone_template] = @zone_template
  end

  it "should show the correct title" do
    render "/templates/form"

    response.should have_tag('h1.underline', 'Update Zone Template')
  end
end
