require 'spec_helper'

describe UsersController do

  describe "without an admin" do
    it "should require a login" do
      get 'index'

      expect(response).to redirect_to( new_user_session_path )
    end
  end

  describe "with an admin" do
    before(:each) do
      @admin = FactoryGirl.create(:admin)
      sign_in( @admin )
    end

    it "should show a list of current users" do
      get 'index'

      expect(response).to render_template( 'users/index')
      expect(assigns(:users)).not_to be_empty
    end

    it 'should load a users details' do
      get 'show', :id => @admin.id

      expect(response).to render_template( 'users/show' )
      expect(assigns(:user)).not_to be_nil
    end

    it 'should have a form for creating a new user' do
      get 'new'

      expect(response).to render_template( 'users/new' )
      expect(assigns(:user)).not_to be_nil
    end

    it "should create a new administrator" do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :admin => 'true'
        }

      expect(assigns(:user)).to be_an_admin

      expect(response).to be_redirect
      expect(response).to redirect_to( user_path( assigns(:user) ) )
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

      expect(assigns(:user).admin?).to be_truthy
      expect(assigns(:user).auth_tokens?).to be_truthy

      expect(response).to be_redirect
      expect(response).to redirect_to( user_path( assigns(:user) ) )
    end

    it "should create a new owner" do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
        }

      expect(assigns(:user)).not_to be_an_admin

      expect(response).to be_redirect
      expect(response).to redirect_to( user_path( assigns(:user) ) )
    end

    it 'should create a new owner ignoring token privs' do
      post :create, :user => {
          :login => 'someone',
          :email => 'someone@example.com',
          :password => 'secret',
          :password_confirmation => 'secret',
          :auth_tokens => '1'
        }

      expect(assigns(:user)).not_to be_an_admin
      expect(assigns(:user).auth_tokens?).to be_falsey

      expect(response).to be_redirect
      expect(response).to redirect_to( user_path( assigns(:user) ) )
    end

    it 'should update a user without password changes' do
      user = FactoryGirl.create(:quentin)

      expect {
        post :update, :id => user.id, :user => {
            :email => 'new@example.com',
            :password => '',
            :password_confirmation => ''
          }
        user.reload
      }.to change( user, :email )

      expect(response).to be_redirect
      expect(response).to redirect_to( user_path( user ) )
    end

    it 'should be able to suspend users' do
      @user = FactoryGirl.create(:quentin)
      put 'suspend', :id => @user.id

      expect(response).to be_redirect
      expect(response).to redirect_to( users_path )
    end
  end
end
