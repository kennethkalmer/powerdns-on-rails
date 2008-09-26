require File.dirname(__FILE__) + '/../spec_helper'

describe AuthToken, "when new" do
  before(:each) do
    @auth_token = AuthToken.new
  end

  it "should be invalid by default" do
    @auth_token.should_not be_valid
  end
  
  it "should require a domain" do
    @auth_token.should have(1).error_on(:domain_id)
  end
  
  it "should require a user" do
    @auth_token.should have(1).error_on(:user_id)
  end
  
  it "should require an auth token" do
    @auth_token.token.should_not be_nil
    
    @auth_token.token = nil
    @auth_token.should have(1).error_on(:token)
  end
  
  it "should require the permissions hash" do
    @auth_token.should have(1).error_on(:permissions)
  end
  
  it "should require an expiry time" do
    @auth_token.should have(1).error_on(:expires_at)
  end
  
  it "should require an expiry time in the future" do
    @auth_token.expires_at = 1.hour.ago
    @auth_token.should have(1).error_on(:expires_at)
  end
  
end

describe AuthToken, "and permissions" do
  fixtures :users, :domains, :records
  
  before(:each) do
    @auth_token = AuthToken.new(
      :user => users(:admin),
      :domain => domains(:example_com),
      :expires_at => 5.hours.since
    )
  end
  
  it "should have a default policy of 'deny'" do
    @auth_token.policy.should eql(:deny)
  end
  
  it "should accept a default policy" do
    @auth_token.policy = :allow
    @auth_token.policy.should eql(:allow)
  end
  
  it "should only accept valid policies" do
    lambda {
      @auth_token.policy = :allow
      @auth_token.policy = :deny
    }.should_not raise_error
    
    lambda {
      @auth_token.policy = :open_sesame
    }.should raise_error
  end
  
  it "should deny new RR's by default" do
    @auth_token.allow_new_records?.should be_false
  end
  
  it "should allow for adding new RR" do
    @auth_token.allow_new_records = true
    @auth_token.allow_new_records?.should be_true
  end
  
  it "should deny removing RR's by default" do
    @auth_token.remove_records?.should be_false
  end
  
  it "should allow for removing RR's" do
    @auth_token.remove_records = true
    @auth_token.remove_records?.should be_true
  end
  
  it "should allow for setting permissions to edit specific RR's (AR)" do
    @auth_token.can_change( records(:example_com_a) )
    @auth_token.can_change?( 'example.com' )
    @auth_token.can_change?( records(:example_com_a) ).should be_true
    @auth_token.can_change?( records(:example_com_a_mail) ).should be_false
  end
  
  it "should allow for setting permissions to edit specific RR's (name)" do
    @auth_token.can_change( 'mail.example.com' )
    @auth_token.can_change?( 'mail.example.com' )
    @auth_token.can_change?( records(:example_com_a) ).should be_false
    @auth_token.can_change?( records(:example_com_a_mail) ).should be_true
  end
  
  it "should allow for protecting certain RR's" do
    @auth_token.policy = :allow
    @auth_token.protect( records(:example_com_a_mail) )
    @auth_token.protect( records(:example_com_mx) )
    
    @auth_token.can_change?( records(:example_com_a) ).should be_true
    @auth_token.can_change?( records(:example_com_a_mail) ).should be_false
  end
  
  it "should allow for protecting RR's by type" do
    @auth_token.policy = :allow
    @auth_token.protect_type 'A'
    
    @auth_token.can_change?( records(:example_com_a_mail) ).should be_false
    @auth_token.can_change?( records(:example_com_mx) ).should be_true
  end
  
  it "should always protect NS records" do
    @auth_token.policy = :allow
    @auth_token.can_change( records(:example_com_ns_ns1) )
    @auth_token.can_change?( records(:example_com_ns_ns2) ).should be_false
  end
  
  it "should always protect SOA records" do
    @auth_token.policy = :allow
    @auth_token.can_change( records(:example_com_soa) )
    @auth_token.can_change?( records(:example_com_soa) ).should be_false
  end
end

describe AuthToken, "and authentication" do
  fixtures :auth_tokens
  
  before(:each) do
    @auth_token = auth_tokens(:token_example_com)
  end
  
  it "should authenticate current tokens" do
    AuthToken.authenticate( '5zuld3g9dv76yosy' ).should eql( @auth_token )
  end
  
  it "should not authenticate expired tokens" do
    AuthToken.authenticate( 'invalid' ).should be_nil
  end
  
  it "should have an easy way to test if it expired" do
    @auth_token.should_not be_expired
    @auth_token.expire
    @auth_token.expires_at.should <( Time.now )
    @auth_token.should be_expired
  end
  
  it "should correctly report the 'token' role" do
    @auth_token.has_role?('token').should be_true
    @auth_token.has_role?('admin').should be_false
  end
end
