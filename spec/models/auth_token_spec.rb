require 'spec_helper'

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
    @auth_token.permissions.should_not be_nil

    @auth_token.permissions = nil
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

describe AuthToken, "internals" do
  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @auth_token = AuthToken.new( :domain => @domain )
  end

  it "should extract the name and RR class from Record objects" do
    record = FactoryGirl.create(:a, :domain => @domain)
    name, type = @auth_token.send(:get_name_and_type_from_param, record )
    name.should eql('example.com')
    type.should eql('A')
  end

  it "should correctly set the name and RR class from string input" do
    name, type = @auth_token.send(:get_name_and_type_from_param, 'example.com', 'A' )
    name.should eql('example.com')
    type.should eql('A')
  end

  it "should correctly set the name and wildcard RR from string input" do
    name, type = @auth_token.send(:get_name_and_type_from_param, 'example.com' )
    name.should eql('example.com')
    type.should eql('*')

    name, type = @auth_token.send(:get_name_and_type_from_param, 'example.com', nil )
    name.should eql('example.com')
    type.should eql('*')
  end

  it "should append the domain name to string records missing it" do
    name, type = @auth_token.send(:get_name_and_type_from_param, 'mail', nil )
    name.should eql('mail.example.com')
    type.should eql('*')
  end

  it 'should take the domain name exactly if given a blank name string' do
    name, type = @auth_token.send(:get_name_and_type_from_param, '')
    name.should eql('example.com')
    type.should eql('*')
  end

end

describe AuthToken, "and permissions" do
  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @auth_token = AuthToken.new(
      :user => FactoryGirl.create(:admin),
      :domain => @domain,
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

    a = FactoryGirl.create(:a, :domain => @domain)
    @auth_token.can_remove?( a ).should be_false
    @auth_token.can_remove?( 'example.com', 'A' ).should be_false

    @auth_token.can_change( a )

    @auth_token.can_remove?( a ).should be_true
    @auth_token.can_remove?( 'example.com', 'A' ).should be_true
  end

  it "should allow for setting permissions to edit specific RR's (AR)" do
    a = FactoryGirl.create(:a, :domain => @domain)
    @auth_token.can_change( a )

    @auth_token.can_change?( 'example.com' ).should be_true
    @auth_token.can_change?( 'example.com', 'MX' ).should be_false

    mx = FactoryGirl.create(:mx, :domain => @domain)
    @auth_token.can_change?( a ).should be_true
    @auth_token.can_change?( mx ).should be_false
  end

  it "should allow for setting permissions to edit specific RR's (name)" do
    a = FactoryGirl.create(:a, :domain => @domain)
    mail = FactoryGirl.create(:a, :name => 'mail', :domain => @domain)

    @auth_token.can_change( 'mail.example.com' )

    @auth_token.can_change?( 'mail.example.com' ).should be_true
    @auth_token.can_change?( mail ).should be_true

    @auth_token.can_change?( a ).should be_false
  end

  it "should allow for protecting certain RR's" do
    mail = FactoryGirl.create(:a, :name => 'mail', :domain => @domain)
    mx = FactoryGirl.create(:mx, :domain => @domain)
    a = FactoryGirl.create(:a, :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.protect( mail )
    @auth_token.protect( mx )

    @auth_token.can_change?( a ).should be_true
    @auth_token.can_change?( 'example.com', 'A' ).should be_true

    @auth_token.can_change?( mx ).should be_false
    @auth_token.can_change?( 'example.com', 'MX' ).should be_false

    @auth_token.can_change?( mail ).should be_false
  end

  it "should allow for protecting RR's by type" do
    mail = FactoryGirl.create(:a, :name => 'mail', :domain => @domain)
    mx = FactoryGirl.create(:mx, :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.protect_type 'A'

    @auth_token.can_change?( mail ).should be_false
    @auth_token.can_change?( mx ).should be_true
  end

  it "should prevent removing RR's by type" do
    mx = FactoryGirl.create(:mx, :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.protect_type 'MX'

    @auth_token.can_remove?( mx ).should be_false
  end

  it "should prevent adding RR's by type" do
    @auth_token.policy = :allow
    @auth_token.allow_new_records = true
    @auth_token.protect_type 'MX'

    @auth_token.can_add?( MX.new( :name => '', :domain => @domain ) ).should be_false
  end

  it "should always protect NS records" do
    ns1 = FactoryGirl.create(:ns, :domain => @domain)
    ns2 = FactoryGirl.create(:ns, :name => 'ns2', :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.remove_records = true
    @auth_token.can_change( ns1 )
    @auth_token.can_change?( ns1 ).should be_false
    @auth_token.can_remove?( ns2 ).should be_false
  end

  it "should always protect SOA records" do
    @auth_token.policy = :allow
    @auth_token.remove_records = true
    @auth_token.can_change( @domain.soa_record )
    @auth_token.can_change?( @domain.soa_record ).should be_false
    @auth_token.can_remove?( @domain.soa_record ).should be_false
  end

  it "should provide a list of new RR types allowed" do
    @auth_token.new_types.should be_empty

    @auth_token.allow_new_records = true
    @auth_token.new_types.include?('MX').should be_true

    @auth_token.protect_type 'MX'
    @auth_token.new_types.include?('MX').should be_false
  end
end

describe AuthToken, "and authentication" do
  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @user = FactoryGirl.create(:admin)
    @auth_token = FactoryGirl.create(:auth_token, :domain => @domain, :user => @user)
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

  it "should correctly report permissions (deserialized)" do
    a = FactoryGirl.create(:a, :domain => @domain)
    @auth_token.can_change?( a ).should be_true
  end
end
