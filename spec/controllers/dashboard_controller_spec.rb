require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController, "and admins" do
  fixtures :all
  
  before(:each) do
    session[:user_id] = users(:admin)
    
    get :index
  end

  it "should have a list of the latest zones" do
    assigns[:latest_domains].should_not be_empty
  end
  
  it "should have a list of templates for quick zone additions" do
    assigns[:zone_templates].should_not be_empty
  end
  
end
