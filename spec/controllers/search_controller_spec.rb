require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  fixtures :all
  
  before(:each) do
    session[:user_id] = users(:admin).id
  end
  
  it "should return results when searched legally" do
    get :results, :q => 'exa'
    
    assigns[:results].should_not be_nil
    response.should render_template('results')
  end
  
  it "should handle whitespace in the query" do
    get :results, :q => ' exa '
    
    assigns[:results].should_not be_nil
    response.should render_template('results')
  end
  
  it "should redirect to the index page when nothing has been searched for" do
    get :results, :q => ''
    
    response.should be_redirect
    response.should redirect_to( root_path )
  end
  
  it "should redirect to the domain page if only one result is found" do
    get :results, :q => 'example.com'
    
    response.should be_redirect
    response.should redirect_to( domain_path( domains(:example_com) ) )
  end

end
