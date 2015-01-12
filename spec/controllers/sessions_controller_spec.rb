require 'spec_helper'

describe SessionsController, "and auth tokens" do

  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @user = FactoryGirl.create(:admin)
    @token = FactoryGirl.create(:auth_token, :domain => @domain, :user => @user)
  end

  xit 'accepts and redirects' do
    post :token, :token => '5zuld3g9dv76yosy'
    session[:token_id].should_not be_nil
    controller.send(:token_user?).should be_true
    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
  end

  xit 'fails login and does not redirect' do
    post :token, :token => 'bad_token'
    session[:token_id].should be_nil
    response.should be_success
  end

  xit 'logs out' do
    tokenize_as(@token)
    get :destroy
    session[:token_id].should be_nil
    response.should redirect_to( session_path )
  end

  xit 'fails expired cookie login' do
    @token.update_attribute :expires_at, 5.minutes.ago
    get :new
    controller.send(:token_user?).should_not be_true
  end

end
