require File.dirname(__FILE__) + '/../spec_helper'

describe User do

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
    quentin = Factory(:quentin)
    quentin.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == quentin
  end

  it 'does not rehash password' do
    quentin = Factory(:quentin)
    quentin.update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'test').should == quentin
  end

  it 'authenticates user' do
    quentin = Factory(:quentin)
    User.authenticate('quentin', 'test').should == quentin
  end

  it 'has roles' do
    Factory(:admin).roles.should_not be_empty
    Factory(:aaron).roles.should be_empty
  end

  it 'sets remember token' do
    quentin = Factory(:quentin)
    quentin.remember_me
    quentin.remember_token.should_not be_nil
    quentin.remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    quentin = Factory(:quentin)
    quentin.remember_me
    quentin.remember_token.should_not be_nil
    quentin.forget_me
    quentin.remember_token.should be_nil
  end

  it 'remembers me for one week' do
    quentin = Factory(:quentin)
    before = 1.week.from_now.utc
    quentin.remember_me_for 1.week
    after = 1.week.from_now.utc
    quentin.remember_token.should_not be_nil
    quentin.remember_token_expires_at.should_not be_nil
    quentin.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    quentin = Factory(:quentin)
    quentin.remember_me_until time
    quentin.remember_token.should_not be_nil
    quentin.remember_token_expires_at.should_not be_nil
    quentin.remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    quentin = Factory(:quentin)
    quentin.remember_me
    after = 2.weeks.from_now.utc
    quentin.remember_token.should_not be_nil
    quentin.remember_token_expires_at.should_not be_nil
    quentin.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'suspends user' do
    quentin = Factory(:quentin)
    quentin.suspend!
    quentin.should be_suspended
  end

  it 'does not authenticate suspended user' do
    quentin = Factory(:quentin)
    quentin.suspend!
    User.authenticate('quentin', 'test').should_not == quentin
  end

  it 'deletes user' do
    quentin = Factory(:quentin)
    quentin.deleted_at.should be_nil
    quentin.delete!
    quentin.deleted_at.should_not be_nil
    quentin.should be_deleted
  end

  describe "being unsuspended" do

    before do
      @user = Factory(:quentin)
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

  before(:each) do
    @user = Factory(:quentin)
    Factory(:domain, :user => @user)
    Factory(:zone_template, :user => @user)
  end

  it "should have domains" do
    @user.domains.should_not be_empty
  end

  it "should have templates" do
    @user.zone_templates.should_not be_empty
  end
end

describe User, "as admin" do

  before(:each) do
    @admin = Factory(:admin)
  end

  it "should not own domains" do
    @admin.domains.should be_empty
  end

  it "should not own zone templates" do
    @admin.zone_templates.should be_empty
  end
end

describe User, "and roles" do

  it "should have a admin boolean flag" do
    Factory( :admin ).admin.should be_true
    Factory( :quentin ).admin.should be_false
  end

  it "should accept string and symbol values for admin value" do
    user = Factory(:quentin)
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
    Factory(:quentin)
    candidates = User.active_owners
    candidates.each do |user|
      user.should be_active
      user.should_not be_admin
    end
  end
end

describe User, "and audits" do

  it "should have username persisted in audits when removed" do
    admin = Factory(:admin)
    Audit.as_user( admin ) do
      domain =Factory(:domain)
      audit = domain.audits.first

      audit.user.should eql( admin )
      audit.username.should be_nil

      admin.destroy
      audit.reload

      audit.user.should eql( 'admin' )
      audit.username.should eql('admin')
    end
  end
end
