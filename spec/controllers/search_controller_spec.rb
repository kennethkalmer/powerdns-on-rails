require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do

  before(:each) do
    session[:user_id] = Factory(:admin).id

    Factory(:domain, :name => 'example.com')
    Factory(:domain, :name => 'example.net')
  end

  it "should return results when searched legally" do
    get :results, :q => 'exa'

    assigns[:results].should_not be_nil
    response.should render_template('search/results')
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
    domain = Factory(:domain, :name => 'slave-example.com')

    get :results, :q => 'slave-example.com'

    response.should be_redirect
    response.should redirect_to( domain_path( domain ) )
  end

end
