require File.dirname(__FILE__) + '/../spec_helper'

describe AuthTokensController do

  it "should not allow access to admins or owners" do
    login_as( Factory(:admin) )
    post :create
    response.code.should eql("401")

    login_as(Factory(:quentin))
    post :create
    response.code.should eql("401")
  end

  it "should bail cleanly on missing auth_token" do
    login_as(Factory(:token_user))

    post :create

    response.code.should eql("422")
  end

  it "should bail cleanly on missing domains" do
    login_as(Factory(:token_user))

    post :create, :auth_token => { :domain => 'example.org' }

    response.code.should eql("404")
  end

  it "bail cleanly on invalid requests" do
    Factory(:domain)

    login_as(Factory(:token_user))

    post :create, :auth_token => { :domain => 'example.com' }

    response.should have_tag('error')
  end

  describe "generating tokens" do

    before(:each) do
      login_as(Factory(:token_user))

      @domain = Factory(:domain)
      @params = { :domain => @domain.name, :expires_at => 1.hour.since.to_s(:rfc822) }
    end

    it "with allow_new set" do
      post :create, :auth_token => @params.merge(:allow_new => 'true')

      response.should have_tag('token') do
        with_tag('expires')
        with_tag('auth_token')
        with_tag('url')
      end

      assigns[:auth_token].should_not be_nil
      assigns[:auth_token].domain.should eql( @domain )
      assigns[:auth_token].should be_allow_new_records
    end

    it "with remove set" do
      a = Factory(:www, :domain => @domain)
      post :create, :auth_token => @params.merge(:remove => 'true', :record => ['www.example.com'])

      response.should have_tag('token') do
        with_tag('expires')
        with_tag('auth_token')
        with_tag('url')
      end

      assigns[:auth_token].remove_records?.should be_true
      assigns[:auth_token].can_remove?( a ).should be_true
    end

    it "with policy set" do
      post :create, :auth_token => @params.merge(:policy => 'allow')

      response.should have_tag('token') do
        with_tag('expires')
        with_tag('auth_token')
        with_tag('url')
      end

      assigns[:auth_token].policy.should eql(:allow)
    end

    it "with protected records" do
      a = Factory(:a, :domain => @domain)
      www = Factory(:www, :domain => @domain)
      mx = Factory(:mx, :domain => @domain)

      post :create, :auth_token => @params.merge(
        :protect => ['example.com:A', 'www.example.com'],
        :policy => 'allow'
      )

      response.should have_tag('token') do
        with_tag('expires')
        with_tag('auth_token')
        with_tag('url')
      end

      assigns[:auth_token].should_not be_nil
      assigns[:auth_token].can_change?( a ).should be_false
      assigns[:auth_token].can_change?( mx ).should be_true
      assigns[:auth_token].can_change?( www ).should be_false
    end

    it "with protected record types" do
      mx = Factory(:mx, :domain => @domain)

      post :create, :auth_token => @params.merge(:policy => 'allow', :protect_type => ['MX'])

      assigns[:auth_token].can_change?( mx ).should be_false
    end

    it "with allowed records" do
      a = Factory(:a, :domain => @domain)
      www = Factory(:www, :domain => @domain)
      mx = Factory(:mx, :domain => @domain)

      post :create, :auth_token => @params.merge(:record => ['example.com'])

      assigns[:auth_token].can_change?( www ).should be_false
      assigns[:auth_token].can_change?( a ).should be_true
      assigns[:auth_token].can_change?( mx ).should be_true
    end

  end
end
