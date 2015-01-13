require 'spec_helper'

describe User do

  it 'suspends user' do
    quentin = FactoryGirl.create(:quentin)
    quentin.suspend!
    expect(quentin).to be_suspended
  end

  it 'does not authenticate suspended user'

  it 'deletes user' do
    quentin = FactoryGirl.create(:quentin)
    expect(quentin.deleted_at).to be_nil
    quentin.delete!
    #quentin.deleted_at.should_not be_nil
    expect(quentin).to be_deleted
  end

  it 'does not authenticate deleted users'

  describe "being unsuspended" do

    before do
      @user = FactoryGirl.create(:quentin)
      @user.suspend!
    end

    it 'reverts to active state' do
      @user.unsuspend!
      expect(@user).to be_active
    end

  end

end

describe User, "as owner" do

  before(:each) do
    @user = FactoryGirl.create(:quentin, :auth_tokens => true)
    FactoryGirl.create(:domain, :user => @user)
    FactoryGirl.create(:zone_template, :user => @user)
  end

  it "should have domains" do
    expect(@user.domains).not_to be_empty
  end

  it "should have templates" do
    expect(@user.zone_templates).not_to be_empty
  end

  it "should not have auth_tokens" do
    expect(@user.auth_tokens?).to be_falsey
  end
end

describe User, "as admin" do

  before(:each) do
    @admin = FactoryGirl.create(:admin, :auth_tokens => true)
  end

  it "should not own domains" do
    expect(@admin.domains).to be_empty
  end

  it "should not own zone templates" do
    expect(@admin.zone_templates).to be_empty
  end

  it "should have auth tokens" do
    expect(@admin.auth_tokens?).to be_truthy
  end
end

describe User, "and roles" do

  it "should have a admin boolean flag" do
    expect(FactoryGirl.create(:admin).admin).to be_truthy
    expect(FactoryGirl.create(:quentin).admin).to be_falsey
  end

  it "should have a way to easily find active owners" do
    FactoryGirl.create(:quentin)
    candidates = User.active_owners
    candidates.each do |user|
      expect(user).to be_active
      expect(user).not_to be_admin
    end
  end
end

describe User, "and audits" do

  it "should have username persisted in audits when removed" do
    admin = FactoryGirl.create(:admin)
    Audit.as_user( admin ) do
      domain =FactoryGirl.create(:domain)
      audit = domain.audits.first

      expect(audit.user).to eql( admin )
      expect(audit.username).to be_nil

      admin.destroy
      audit.reload

      expect(audit.user).to eql( 'admin' )
      expect(audit.username).to eql('admin')
    end
  end
end
