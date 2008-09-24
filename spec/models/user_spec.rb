require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end

    it 'starts in active state' do
      @creating_user.call
      @user.reload
      @user.should be_active
    end
  end

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    User.authenticate('quentin', 'test').should == users(:quentin)
  end
  
  it 'has roles' do
    users(:admin).roles.should_not be_empty
    users(:aaron).roles.should be_empty
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'suspends user' do
    users(:quentin).suspend!
    users(:quentin).should be_suspended
  end

  it 'does not authenticate suspended user' do
    users(:quentin).suspend!
    User.authenticate('quentin', 'test').should_not == users(:quentin)
  end

  it 'deletes user' do
    users(:quentin).deleted_at.should be_nil
    users(:quentin).delete!
    users(:quentin).deleted_at.should_not be_nil
    users(:quentin).should be_deleted
  end

  describe "being unsuspended" do
    fixtures :users

    before do
      @user = users(:quentin)
      @user.suspend!
    end
    
    it 'reverts to active state' do
      @user.unsuspend!
      @user.should be_active
    end
    
  end

protected
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end

describe User, "as owner" do
  fixtures :all
  
  before(:each) do
    @user = users( :quentin )
  end
  
  it "should have domains" do
    @user.domains.should_not be_empty
  end
  
  it "should have templates" do
    @user.zone_templates.should_not be_empty
  end
end

describe User, "as admin" do
  fixtures :all
  
  before(:each) do
    @admin = users(:admin)
  end
  
  it "should not own domains" do
    @admin.domains.should be_empty
  end
  
  it "should not own zone templates" do
    @admin.zone_templates.should be_empty
  end
end

describe User, "and roles" do
  fixtures :all
  
  it "should have a admin boolean flag" do
    users( :admin ).admin.should be_true
    users( :quentin ).admin.should be_false
  end
  
  it "should accept string and symbol values for admin value" do
    user = users(:quentin)
    user.should_not be_admin
    
    user.admin = "true"
    user.should be_admin
    user.reload
    
    user.admin = :true
    user.should be_admin
    user.reload
    
    # Kinda pointless, but good for rcov
    user.admin = 911
    user.admin.should be(911)
  end
  
  it "should have a way to easily find active owners" do
    candidates = User.active_owners
    candidates.each do |user|
      user.should be_active
      user.should_not be_admin
    end
  end
end

describe User, "and audits" do
  fixtures :all
  
  it "should have username persisted in audits when removed" do
    audit = audits(:example_com_erronous_a_removed)
    admin = users(:admin)
    
    audit.user.should eql( admin )
    audit.username.should be_nil
    
    admin.destroy
    audit.reload
    
    audit.user.should eql( 'admin' ) 
    audit.username.should eql('admin')
  end
end
