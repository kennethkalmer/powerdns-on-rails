require File.dirname(__FILE__) + '/../spec_helper'

describe TemplatesController, "and admins" do
  fixtures :all
  
  before(:each) do
    session[:user_id] = users(:admin).id
  end
  
  it "should have a template list" do
    get :index
    
    assigns[:zone_templates].should_not be_empty
    assigns[:zone_templates].size.should be( ZoneTemplate.count )
  end

  it "should have a list of users when showing the new form" do
    get :new
    
    assigns[:users].should_not be_empty
    assigns[:users].each { |u| u.has_role?('owner').should be_true }
  end
end

describe TemplatesController, "and users" do
  fixtures :all
  
  before(:each) do
    session[:user_id] = users(:quentin).id
  end
  
  it "should have a limited list" do
    get :index
    
    assigns[:zone_templates].should_not be_empty
    assigns[:zone_templates].size.should be(1)
  end
  
  it "should not have a list of users when showing the new form" do
    get :new
    
    assigns[:users].should be_nil
  end
end