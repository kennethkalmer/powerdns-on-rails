require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController, "and users" do
  before(:each) do
    @quentin = Factory(:quentin)
  end

  it 'logins and redirects' do
    post :create, :login => 'quentin', :password => 'test'
    session[:user_id].should_not be_nil
    response.should be_redirect
  end

  it 'fails login and does not redirect' do
    post :create, :login => 'quentin', :password => 'bad password'
    session[:user_id].should be_nil
    response.should be_success
  end

  it 'logs out' do
    login_as @quentin
    get :destroy
    session[:user_id].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end

  it 'does not remember me' do
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    login_as @quentin
    get :destroy
    response.cookies["auth_token"].should be_nil
  end

  it 'logs in with cookie' do
    @quentin.remember_me
    request.cookies["auth_token"] = cookie_for(@quentin)
    get :new
    controller.send(:logged_in?).should be_true
  end

  it 'fails expired cookie login' do
    @quentin.remember_me
    @quentin.update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(@quentin)
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  it 'fails cookie login' do
    @quentin.remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token user.remember_token
  end
end

describe SessionsController, "and auth tokens" do

  before(:each) do
    @domain = Factory(:domain)
    @user = Factory(:admin)
    @token = Factory(:auth_token, :domain => @domain, :user => @user)
  end

  it 'accepts and redirects' do
    post :token, :token => '5zuld3g9dv76yosy'
    session[:token_id].should_not be_nil
    controller.send(:token_user?).should be_true
    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
  end

  it 'fails login and does not redirect' do
    post :token, :token => 'bad_token'
    session[:token_id].should be_nil
    response.should be_success
  end

  it 'logs out' do
    tokenize_as(@token)
    get :destroy
    session[:token_id].should be_nil
    response.should redirect_to( session_path )
  end

  it 'fails expired cookie login' do
    @token.update_attribute :expires_at, 5.minutes.ago
    get :new
    controller.send(:token_user?).should_not be_true
  end

end
