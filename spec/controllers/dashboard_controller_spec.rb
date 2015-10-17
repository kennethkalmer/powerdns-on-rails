require 'spec_helper'

describe DashboardController, "and admins" do

  before(:each) do
    sign_in( FactoryGirl.create(:admin) )

    FactoryGirl.create(:domain)

    get :index
  end

  it "should have a list of the latest zones" do
    expect(assigns(:latest_domains)).not_to be_empty
  end

end
