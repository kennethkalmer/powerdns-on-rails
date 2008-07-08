require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  fixtures :users
  
  before(:each) do
    session[:user_id] = users(:admin).id
  end
  
  it "should do nothing if the search parameters are blank" do
    post :results, :search => { :parameters => "" }
    
    response.should be_redirect
    response.should redirect_to( root_path )
  end
  
  it "should display the results of a valid search" do
    post :results, :search => { :parameters => "example" }
    
    assigns[:zones].should_not be_empty
    response.should be_success
    response.should render_template("results")
  end

end
