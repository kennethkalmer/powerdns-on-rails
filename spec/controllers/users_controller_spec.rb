require 'spec_helper'

describe UsersController do

  describe "without an admin" do
    it "should require a login" do
      get 'index'

      response.should redirect_to( new_user_session_path )
    end
  end

  describe "with an admin" do
    before(:each) do
      @admin = FactoryGirl.create(:admin)
      sign_in( @admin )
    end

    it "should show a list of current users" do
      get 'index'

      response.should render_template( 'users/index')
      assigns(:users).should_not be_empty
    end

    it 'should load a users details' do
      get 'show', :id => @admin.id

      response.should render_template( 'users/show' )
      assigns(:user).should_not be_nil
    end

    it 'should have a form for creating a new user' do
      get 'new'

      response.should render_template( 'users/new' )
      assigns(:user).should_not be_nil
    end

    it "should create a new administrator" do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :admin => 'true'
        }

      assigns(:user).should be_an_admin

      response.should be_redirect
      response.should redirect_to( user_path( assigns(:user) ) )
    end

    it 'should create a new administrator with token privs' do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :admin => '1',
          :auth_tokens => '1'
        }

      assigns(:user).admin?.should be_true
      assigns(:user).auth_tokens?.should be_true

      response.should be_redirect
      response.should redirect_to( user_path( assigns(:user) ) )
    end

    it "should create a new owner" do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
        }

      assigns(:user).should_not be_an_admin

      response.should be_redirect
      response.should redirect_to( user_path( assigns(:user) ) )
    end

    it 'should create a new owner ignoring token privs' do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :auth_tokens => '1'
        }

      assigns(:user).should_not be_an_admin
      assigns(:user).auth_tokens?.should be_false

      response.should be_redirect
      response.should redirect_to( user_path( assigns(:user) ) )
    end

    it 'should update a user without password changes' do
      user = FactoryGirl.create(:quentin)

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
      @user = FactoryGirl.create(:quentin)
      put 'suspend', :id => @user.id

      response.should be_redirect
      response.should redirect_to( users_path )
    end
  end
end
