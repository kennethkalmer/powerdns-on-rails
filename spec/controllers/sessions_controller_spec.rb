require 'spec_helper'

describe SessionsController, "and auth tokens" do

  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @user = FactoryGirl.create(:admin)
    @token = FactoryGirl.create(:auth_token, :domain => @domain, :user => @user)
  end

  xit 'accepts and redirects' do
    post :token, :token => '5zuld3g9dv76yosy'
    expect(session[:token_id]).not_to be_nil
    expect(controller.send(:token_user?)).to be_truthy
    expect(response).to be_redirect
    expect(response).to redirect_to( domain_path( @domain ) )
  end

  xit 'fails login and does not redirect' do
    post :token, :token => 'bad_token'
    expect(session[:token_id]).to be_nil
    expect(response).to be_success
  end

  xit 'logs out' do
    tokenize_as(@token)
    get :destroy
    expect(session[:token_id]).to be_nil
    expect(response).to redirect_to( session_path )
  end

  xit 'fails expired cookie login' do
    @token.update_attribute :expires_at, 5.minutes.ago
    get :new
    expect(controller.send(:token_user?)).not_to be_truthy
  end

end
