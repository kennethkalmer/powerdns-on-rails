require File.dirname(__FILE__) + '/../spec_helper'

describe TemplatesController, "and admins" do
  before(:each) do
    login_as(Factory(:admin))
  end

  it "should have a template list" do
    Factory(:zone_template)

    get :index

    assigns[:zone_templates].should_not be_empty
    assigns[:zone_templates].size.should be( ZoneTemplate.count )
  end

  it "should have a list of users when showing the new form" do
    Factory(:quentin)

    get :new

    assigns[:users].should_not be_empty
    assigns[:users].each { |u| u.has_role?('owner').should be_true }
  end

  it "should have a detailed view of a template" do
    get :show, :id => Factory(:zone_template).id

    assigns[:zone_template].should_not be_nil
    assigns[:record_template].should be_a_new_record

    response.should render_template('templates/show')
  end

end

describe TemplatesController, "and users" do
  before(:each) do
    @quentin = Factory(:quentin)
    login_as(@quentin)
  end

  it "should have a limited list" do
    Factory(:zone_template, :user => @quentin)
    Factory(:zone_template, :name => '!Quentin')

    get :index

    assigns[:zone_templates].should_not be_empty
    assigns[:zone_templates].size.should be(1)
  end

  it "should not have a list of users when showing the new form" do
    get :new

    assigns[:users].should be_nil
  end
end

describe TemplatesController, "should handle a REST client" do
  before(:each) do
    authorize_as(Factory(:api_client))
  end

  it "asking for a list of templates" do
    Factory(:zone_template)

    get :index, :format => "xml"

    response.should have_tag('zone-templates') do
      with_tag('zone-template')
    end
  end
end
