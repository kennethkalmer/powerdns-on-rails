require 'spec_helper'

describe AuditsController do

  before(:each) do
    sign_in(Factory(:admin))
  end

  it "should have a search form" do
    get :index

    response.should render_template('audits/index')
  end

  it "should have a domain details page" do
    get :domain, :id => Factory(:domain).id

    assigns(:domain).should_not be_nil

    response.should render_template('audits/domain')
  end
end
