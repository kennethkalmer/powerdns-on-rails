require File.dirname(__FILE__) + '/../spec_helper'

describe AuthTokensController do
  fixtures :all
  
  it "should not allow access to admins or owners" do
    login_as(:admin)
    post :create
    response.code.should eql("401")
    
    login_as(:quentin)
    post :create
    response.code.should eql("401")
  end
  
  it "should bail cleanly on missing auth_token" do
    login_as(:token_user)

    post :create

    response.code.should eql("422")
  end
  
  it "should bail cleanly on missing domains" do
    login_as(:token_user)
    
    post :create, :auth_token => { :domain => 'example.org' }
    
    response.code.should eql("404")
  end
  
  it "bail cleanly on invalid requests" do
    login_as(:token_user)
    
    post :create, :auth_token => { :domain => 'example.com' }
    
    response.should have_tag('error')
  end
  
  describe "generating tokens" do
    
    before(:each) do
      login_as(:token_user)
      
      @domain = domains(:example_com)
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
      assigns[:auth_token].domain.should eql( domains(:example_com) )
      assigns[:auth_token].should be_allow_new_records
    end
    
    it "with remove set" do
      post :create, :auth_token => @params.merge(:remove => 'true', :record => ['www.example.com'])
      
      response.should have_tag('token') do
        with_tag('expires')
        with_tag('auth_token')
        with_tag('url')
      end
      
      assigns[:auth_token].remove_records?.should be_true
      assigns[:auth_token].can_remove?( records(:example_com_a_www) ).should be_true
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
      assigns[:auth_token].can_change?( records(:example_com_a) ).should be_false
      assigns[:auth_token].can_change?( records(:example_com_mx) ).should be_true
      assigns[:auth_token].can_change?( records(:example_com_a_www) ).should be_false
    end
    
    it "with protected record types" do
      post :create, :auth_token => @params.merge(:policy => 'allow', :protect_type => ['MX'])
      
      assigns[:auth_token].can_change?( records(:example_com_mx) ).should be_false
    end
    
    it "with allowed records" do
      post :create, :auth_token => @params.merge(:record => ['example.com'])
      
      assigns[:auth_token].can_change?( records(:example_com_a_www) ).should be_false
      assigns[:auth_token].can_change?( records(:example_com_a) ).should be_true
      assigns[:auth_token].can_change?( records(:example_com_mx) ).should be_true
    end
    
  end
end
