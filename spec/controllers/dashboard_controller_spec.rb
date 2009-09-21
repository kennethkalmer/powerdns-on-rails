require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController, "and admins" do

  before(:each) do
    login_as( Factory(:admin) )

    Factory(:domain)

    zt = Factory(:zone_template)
    Factory(:template_soa, :zone_template => zt)

    get :index
  end

  it "should have a list of the latest zones" do
    assigns[:latest_domains].should_not be_empty
  end

  it "should have a list of templates for quick zone additions" do
    assigns[:zone_templates].should_not be_empty
  end

end
