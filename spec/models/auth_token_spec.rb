require 'spec_helper'

describe AuthToken, "when new" do

  it "should be invalid by default" do
    expect(subject).not_to be_valid
  end

  it "should require a domain" do
    subject.valid?
    expect( subject.errors[:domain_id].size ).to eq(1)
  end

  it "should require a user" do
    subject.valid?
    expect( subject.errors[:user_id].size ).to eq(1)
  end

  it "should require an auth token" do
    expect(subject.token).not_to be_nil

    subject.token = nil
    subject.valid?
    expect( subject.errors[:token].size ).to eq(1)
  end

  it "should require the permissions hash" do
    expect(subject.permissions).not_to be_nil

    subject.permissions = nil
    subject.valid?
    expect( subject.errors[:permissions].size ).to eq(1)
  end

  it "should require an expiry time" do
    subject.valid?
    expect( subject.errors[:expires_at].size ).to eq(1)
  end

  it "should require an expiry time in the future" do
    subject.expires_at = 1.hour.ago
    subject.valid?
    expect( subject.errors[:expires_at].size ).to eq(1)
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
    expect(name).to eql('example.com')
    expect(type).to eql('A')
  end

  it "should correctly set the name and RR class from string input" do
    name, type = @auth_token.send(:get_name_and_type_from_param, 'example.com', 'A' )
    expect(name).to eql('example.com')
    expect(type).to eql('A')
  end

  it "should correctly set the name and wildcard RR from string input" do
    name, type = @auth_token.send(:get_name_and_type_from_param, 'example.com' )
    expect(name).to eql('example.com')
    expect(type).to eql('*')

    name, type = @auth_token.send(:get_name_and_type_from_param, 'example.com', nil )
    expect(name).to eql('example.com')
    expect(type).to eql('*')
  end

  it "should append the domain name to string records missing it" do
    name, type = @auth_token.send(:get_name_and_type_from_param, 'mail', nil )
    expect(name).to eql('mail.example.com')
    expect(type).to eql('*')
  end

  it 'should take the domain name exactly if given a blank name string' do
    name, type = @auth_token.send(:get_name_and_type_from_param, '')
    expect(name).to eql('example.com')
    expect(type).to eql('*')
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
    expect(@auth_token.policy).to eql(:deny)
  end

  it "should accept a default policy" do
    @auth_token.policy = :allow
    expect(@auth_token.policy).to eql(:allow)
  end

  it "should only accept valid policies" do
    expect {
      @auth_token.policy = :allow
      @auth_token.policy = :deny
    }.not_to raise_error

    expect {
      @auth_token.policy = :open_sesame
    }.to raise_error
  end

  it "should deny new RR's by default" do
    expect(@auth_token.allow_new_records?).to be false
  end

  it "should allow for adding new RR" do
    @auth_token.allow_new_records = true
    expect(@auth_token.allow_new_records?).to be true
  end

  it "should deny removing RR's by default" do
    expect(@auth_token.remove_records?).to be false
  end

  it "should allow for removing RR's" do
    @auth_token.remove_records = true
    expect(@auth_token.remove_records?).to be true

    a = FactoryGirl.create(:a, :domain => @domain)
    expect(@auth_token.can_remove?( a )).to be false
    expect(@auth_token.can_remove?( 'example.com', 'A' )).to be false

    @auth_token.can_change( a )

    expect(@auth_token.can_remove?( a )).to be true
    expect(@auth_token.can_remove?( 'example.com', 'A' )).to be true
  end

  it "should allow for setting permissions to edit specific RR's (AR)" do
    a = FactoryGirl.create(:a, :domain => @domain)
    @auth_token.can_change( a )

    expect(@auth_token.can_change?( 'example.com' )).to be true
    expect(@auth_token.can_change?( 'example.com', 'MX' )).to be false

    mx = FactoryGirl.create(:mx, :domain => @domain)
    expect(@auth_token.can_change?( a )).to be true
    expect(@auth_token.can_change?( mx )).to be false
  end

  it "should allow for setting permissions to edit specific RR's (name)" do
    a = FactoryGirl.create(:a, :domain => @domain)
    mail = FactoryGirl.create(:a, :name => 'mail', :domain => @domain)

    @auth_token.can_change( 'mail.example.com' )

    expect(@auth_token.can_change?( 'mail.example.com' )).to be true
    expect(@auth_token.can_change?( mail )).to be true

    expect(@auth_token.can_change?( a )).to be false
  end

  it "should allow for protecting certain RR's" do
    mail = FactoryGirl.create(:a, :name => 'mail', :domain => @domain)
    mx = FactoryGirl.create(:mx, :domain => @domain)
    a = FactoryGirl.create(:a, :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.protect( mail )
    @auth_token.protect( mx )

    expect(@auth_token.can_change?( a )).to be true
    expect(@auth_token.can_change?( 'example.com', 'A' )).to be true

    expect(@auth_token.can_change?( mx )).to be false
    expect(@auth_token.can_change?( 'example.com', 'MX' )).to be false

    expect(@auth_token.can_change?( mail )).to be false
  end

  it "should allow for protecting RR's by type" do
    mail = FactoryGirl.create(:a, :name => 'mail', :domain => @domain)
    mx = FactoryGirl.create(:mx, :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.protect_type 'A'

    expect(@auth_token.can_change?( mail )).to be false
    expect(@auth_token.can_change?( mx )).to be true
  end

  it "should prevent removing RR's by type" do
    mx = FactoryGirl.create(:mx, :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.protect_type 'MX'

    expect(@auth_token.can_remove?( mx )).to be false
  end

  it "should prevent adding RR's by type" do
    @auth_token.policy = :allow
    @auth_token.allow_new_records = true
    @auth_token.protect_type 'MX'

    expect(@auth_token.can_add?( MX.new( :name => '', :domain => @domain ) )).to be false
  end

  it "should always protect NS records" do
    ns1 = FactoryGirl.create(:ns, :domain => @domain)
    ns2 = FactoryGirl.create(:ns, :name => 'ns2', :domain => @domain)

    @auth_token.policy = :allow
    @auth_token.remove_records = true
    @auth_token.can_change( ns1 )
    expect(@auth_token.can_change?( ns1 )).to be false
    expect(@auth_token.can_remove?( ns2 )).to be false
  end

  it "should always protect SOA records" do
    @auth_token.policy = :allow
    @auth_token.remove_records = true
    @auth_token.can_change( @domain.soa_record )
    expect(@auth_token.can_change?( @domain.soa_record )).to be false
    expect(@auth_token.can_remove?( @domain.soa_record )).to be false
  end

  it "should provide a list of new RR types allowed" do
    expect(@auth_token.new_types).to be_empty

    @auth_token.allow_new_records = true
    expect(@auth_token.new_types.include?('MX')).to be true

    @auth_token.protect_type 'MX'
    expect(@auth_token.new_types.include?('MX')).to be false
  end
end

describe AuthToken, "and authentication" do
  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @user = FactoryGirl.create(:admin)
    @auth_token = FactoryGirl.create(:auth_token, :domain => @domain, :user => @user)
  end

  it "should authenticate current tokens" do
    expect(AuthToken.authenticate( '5zuld3g9dv76yosy' )).to eql( @auth_token )
  end

  it "should not authenticate expired tokens" do
    expect(AuthToken.authenticate( 'invalid' )).to be_nil
  end

  it "should have an easy way to test if it expired" do
    expect(@auth_token).not_to be_expired
    @auth_token.expire
    expect(@auth_token.expires_at).to be <( Time.now )
    expect(@auth_token).to be_expired
  end

  it "should correctly report the 'token' role" do
    expect(@auth_token.has_role?('token')).to be true
    expect(@auth_token.has_role?('admin')).to be false
  end

  it "should correctly report permissions (deserialized)" do
    a = FactoryGirl.create(:a, :domain => @domain)
    expect(@auth_token.can_change?( a )).to be true
  end
end
