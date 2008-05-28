require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  
  describe "without an admin" do
    it "should require a login" do
      get 'index'
      
      response.should redirect_to( new_session_path )
    end
  end
  
  describe "with an admin" do
    fixtures :all
    
    before(:each) do
      login_as( :admin )
    end
    
    it "should show a list of current users" do
      get 'index'
      
      response.should render_template( 'users/index')
      assigns[:users].should_not be_empty
    end
    
    it 'should load a users details' do
      get 'show', :id => users(:admin).id
      
      response.should render_template( 'users/show' )
      assigns[:user].should_not be_nil
    end
    
    it 'should have a form for creating a new user' do
      get 'new'
      
      response.should render_template( 'users/form' )
      assigns[:user].should_not be_nil
    end
    
  end
end
