require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do

  describe "without an admin" do
    it "should require a login" do
      get 'index'

      response.should redirect_to( new_session_path )
    end
  end

  describe "with an admin" do
    before(:each) do
      @admin = Factory(:admin)
      login_as( @admin )
    end

    it "should show a list of current users" do
      get 'index'

      response.should render_template( 'users/index')
      assigns[:users].should_not be_empty
    end

    it 'should load a users details' do
      get 'show', :id => @admin.id

      response.should render_template( 'users/show' )
      assigns[:user].should_not be_nil
    end

    it 'should have a form for creating a new user' do
      get 'new'

      response.should render_template( 'users/form' )
      assigns[:user].should_not be_nil
    end

    it "should create a new administrator" do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :admin => 'true'
        }

      assigns[:user].should be_an_admin

      response.should be_redirect
      response.should redirect_to( user_path( assigns[:user] ) )
    end

    it 'should create a new administrator with token privs' do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :admin => 'true'
        },
        :token_user => '1'

      assigns[:user].should be_an_admin
      assigns[:user].has_role?('auth_token').should be_true

      response.should be_redirect
      response.should redirect_to( user_path( assigns[:user] ) )
    end

    it "should create a new owner" do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :admin => 'false'
        }

      assigns[:user].should_not be_an_admin

      response.should be_redirect
      response.should redirect_to( user_path( assigns[:user] ) )
    end

    it 'should create a new owner ignoring token privs' do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :admin => 'false'
        },
        :token_user => '1'

      assigns[:user].should_not be_an_admin
      assigns[:user].has_role?('auth_token').should be_false

      response.should be_redirect
      response.should redirect_to( user_path( assigns[:user] ) )
    end

    it 'should update a user without password changes' do
      user = Factory(:quentin)

      lambda {
        post :update, :id => user.id, :user => {
            :email => 'new@example.com',
            :password => '',
            :password_confirmation => ''
          }
        user.reload
      }.should change( user, :email )

      response.should be_redirect
      response.should redirect_to( user_path( user ) )
    end

    it 'should be able to suspend users' do
      @user = Factory(:quentin)
      put 'suspend', :id => @user.id

      response.should be_redirect
      response.should redirect_to( users_path )
    end
  end
end
