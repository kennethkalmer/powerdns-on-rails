require 'spec_helper'

describe TemplatesController, "and admins" do
  before(:each) do
    sign_in(FactoryGirl.create(:admin))
  end

  it "should have a template list" do
    FactoryGirl.create(:zone_template)

    get :index

    assigns(:zone_templates).should_not be_empty
    assigns(:zone_templates).size.should be( ZoneTemplate.count )
  end

  it "should have a detailed view of a template" do
    get :show, :id => FactoryGirl.create(:zone_template).id

    assigns(:zone_template).should_not be_nil

    response.should render_template('templates/show')
  end

  it "should redirect to the template on create" do
    expect {
      post :create, :zone_template => { :name => 'Foo' }
    }.to change( ZoneTemplate, :count ).by(1)

    response.should redirect_to( zone_template_path( assigns(:zone_template) ) )
  end

end

describe TemplatesController, "and users" do
  before(:each) do
    @quentin = FactoryGirl.create(:quentin)
    sign_in(@quentin)
  end

  it "should have a limited list" do
    FactoryGirl.create(:zone_template, :user => @quentin)
    FactoryGirl.create(:zone_template, :name => '!Quentin')

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
    sign_in(FactoryGirl.create(:api_client))
  end

  it "asking for a list of templates" do
    FactoryGirl.create(:zone_template)

    get :index, :format => "xml"

    response.should have_tag('zone-templates > zone-template')
  end
end
