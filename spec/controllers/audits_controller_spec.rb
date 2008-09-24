require File.dirname(__FILE__) + '/../spec_helper'

describe AuditsController do
  fixtures :users, :domains, :records
  
  before(:each) do
    login_as(:admin)
  end
  
  it "should have a search form" do
    get :index
    
    pending
  end

  it "should have a domain details page" do
    get :domain, :id => domains(:example_com).id
    
    assigns[:domain].should_not be_nil
    
    response.should render_template('domain')
  end
end
