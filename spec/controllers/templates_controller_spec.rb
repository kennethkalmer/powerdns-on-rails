require 'spec_helper'

describe TemplatesController, "and admins" do
  before(:each) do
    sign_in(Factory(:admin))
  end

  it "should have a template list" do
    Factory(:zone_template)

    get :index

    assigns(:zone_templates).should_not be_empty
    assigns(:zone_templates).size.should be( ZoneTemplate.count )
  end

  it "should have a detailed view of a template" do
    get :show, :id => Factory(:zone_template).id

    assigns(:zone_template).should_not be_nil

    response.should render_template('templates/show')
  end

end

describe TemplatesController, "and users" do
  before(:each) do
    @quentin = Factory(:quentin)
    sign_in(@quentin)
  end

  it "should have a limited list" do
    Factory(:zone_template, :user => @quentin)
    Factory(:zone_template, :name => '!Quentin')

    get :index

    assigns(:zone_templates).should_not be_empty
    assigns(:zone_templates).size.should be(1)
  end

  it "should not have a list of users when showing the new form" do
    get :new

    assigns(:users).should be_nil
  end
end

describe TemplatesController, "should handle a REST client" do
  before(:each) do
    sign_in(Factory(:api_client))
  end

  it "asking for a list of templates" do
    Factory(:zone_template)

    get :index, :format => "xml"

    response.should have_tag('zone-templates > zone-template')
  end
end
