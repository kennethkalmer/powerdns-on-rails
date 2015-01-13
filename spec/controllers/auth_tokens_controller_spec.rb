require 'spec_helper'

describe AuthTokensController do

  it "should not allow access to admins or owners" do
    sign_in( FactoryGirl.create(:admin) )
    post :create
    expect(response.code).to eql("302")

    sign_in(FactoryGirl.create(:quentin))
    post :create
    expect(response.code).to eql("302")
  end

  it "should bail cleanly on missing auth_token" do
    sign_in(FactoryGirl.create(:token_user))

    post :create

    expect(response.code).to eql("422")
  end

  it "should bail cleanly on missing domains" do
    sign_in(FactoryGirl.create(:token_user))

    post :create, :auth_token => { :domain => 'example.org' }

    expect(response.code).to eql("404")
  end

  it "bail cleanly on invalid requests" do
    FactoryGirl.create(:domain)

    sign_in(FactoryGirl.create(:token_user))

    post :create, :auth_token => { :domain => 'example.com' }

    expect(response).to have_selector('error')
  end

  describe "generating tokens" do

    before(:each) do
      sign_in(FactoryGirl.create(:token_user))

      @domain = FactoryGirl.create(:domain)
      @params = { :domain => @domain.name, :expires_at => 1.hour.since.to_s(:rfc822) }
    end

    it "with allow_new set" do
      post :create, :auth_token => @params.merge(:allow_new => 'true')

      expect(response).to have_selector('token > expires')
      expect(response).to have_selector('token > auth_token')
      expect(response).to have_selector('token > url')

      expect(assigns(:auth_token)).not_to be_nil
      expect(assigns(:auth_token).domain).to eql( @domain )
      expect(assigns(:auth_token)).to be_allow_new_records
    end

    it "with remove set" do
      a = FactoryGirl.create(:www, :domain => @domain)
      post :create, :auth_token => @params.merge(:remove => 'true', :record => ['www.example.com'])

      expect(response).to have_selector('token > expires')
      expect(response).to have_selector('token > auth_token')
      expect(response).to have_selector('token > url')

      expect(assigns(:auth_token).remove_records?).to be_truthy
      expect(assigns(:auth_token).can_remove?( a )).to be_truthy
    end

    it "with policy set" do
      post :create, :auth_token => @params.merge(:policy => 'allow')

      expect(response).to have_selector('token > expires')
      expect(response).to have_selector('token > auth_token')
      expect(response).to have_selector('token > url')

      expect(assigns(:auth_token).policy).to eql(:allow)
    end

    it "with protected records" do
      a = FactoryGirl.create(:a, :domain => @domain)
      www = FactoryGirl.create(:www, :domain => @domain)
      mx = FactoryGirl.create(:mx, :domain => @domain)

      post :create, :auth_token => @params.merge(
        :protect => ['example.com:A', 'www.example.com'],
        :policy => 'allow'
      )

      expect(response).to have_selector('token > expires')
      expect(response).to have_selector('token > auth_token')
      expect(response).to have_selector('token > url')

      expect(assigns(:auth_token)).not_to be_nil
      expect(assigns(:auth_token).can_change?( a )).to be_falsey
      expect(assigns(:auth_token).can_change?( mx )).to be_truthy
      expect(assigns(:auth_token).can_change?( www )).to be_falsey
    end

    it "with protected record types" do
      mx = FactoryGirl.create(:mx, :domain => @domain)

      post :create, :auth_token => @params.merge(:policy => 'allow', :protect_type => ['MX'])

      expect(assigns(:auth_token).can_change?( mx )).to be_falsey
    end

    it "with allowed records" do
      a = FactoryGirl.create(:a, :domain => @domain)
      www = FactoryGirl.create(:www, :domain => @domain)
      mx = FactoryGirl.create(:mx, :domain => @domain)

      post :create, :auth_token => @params.merge(:record => ['example.com'])

      expect(assigns(:auth_token).can_change?( www )).to be_falsey
      expect(assigns(:auth_token).can_change?( a )).to be_truthy
      expect(assigns(:auth_token).can_change?( mx )).to be_truthy
    end

  end
end
