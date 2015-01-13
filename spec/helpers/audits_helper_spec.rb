require 'spec_helper'

describe AuditsHelper, "display_hash" do

  it "should handle a blank changes hash" do
    expect(helper.display_hash( nil )).to eql('')
  end

  it "should have a way to display the changes hash with blank stipped" do
    result = helper.display_hash( 'key' => 'value', :blank => nil )
    expect(result).to eql("<em>key</em>: value")
  end

  it "should seperate items in the change hash with breaks" do
    result = helper.display_hash( 'one' => 'one', 'two' => 'two' )
    expect(result).to match(/<br \/>/)
  end

end

describe AuditsHelper, "link_to_domain_audit" do

  it "should handle an existing domain & existing user" do
    Audit.as_user( FactoryGirl.create(:admin) ) do
      domain = FactoryGirl.create(:domain)
      audit = domain.audits.first

      results = helper.link_to_domain_audit( audit )

      expect(results).to match(/1 create by admin/)
    end
  end

  it "should handle existing domains & removed users" do
    Audit.as_user('admin') do
    audit = FactoryGirl.create(:domain).audits.first

      results = helper.link_to_domain_audit( audit )

      expect(results).to match(/1 create by admin/)
    end
  end

  it "should handle removed domains & existing users" do
    Audit.as_user( FactoryGirl.create(:admin) ) do
      domain = FactoryGirl.create(:domain)
      domain.destroy
      audit = domain.audits.last

      results = helper.link_to_domain_audit( audit )

      expect(results).to match(/2 destroy by admin/)
    end
  end

  it "should handle removed domains & removed users" do
    Audit.as_user('admin') do
      domain = FactoryGirl.create(:domain)
      domain.destroy
      audit = domain.audits.last

      results = helper.link_to_domain_audit( audit )

      expect(results).to match(/2 destroy by admin/)
    end
  end

end

describe AuditsHelper, "link_to_record_audit" do

  it "should handle an existing record & existing user" do
    Audit.as_user( FactoryGirl.create(:admin) ) do
      domain = FactoryGirl.create(:domain)
      record = FactoryGirl.create(:a, :domain => domain)
      audit = record.audits.first

      result = helper.link_to_record_audit( audit )
      expect(result).to match(/A \(example\.com\) 1 create by admin/)
    end
  end

  it "should handle existing records & removed users" do
    Audit.as_user( 'admin' ) do
      domain = FactoryGirl.create(:domain)
      record = FactoryGirl.create(:a, :domain => domain)
      audit = record.audits.first

      result = helper.link_to_record_audit( audit )
      expect(result).to match(/A \(example\.com\) 1 create by admin/)
    end
  end

  it "should handle removed records & existing users" do
    Audit.as_user( FactoryGirl.create(:admin) ) do
      domain = FactoryGirl.create(:domain)
      record = FactoryGirl.create(:a, :domain => domain)
      record.destroy
      audit = record.audits.last

      result = helper.link_to_record_audit( audit )
      expect(result).to match(/A \(example\.com\) 2 destroy by admin/)
    end
  end

  it "should handle removed records & removed users" do
    Audit.as_user( 'admin' ) do
      domain = FactoryGirl.create(:domain)
      record = FactoryGirl.create(:a, :domain => domain)
      record.destroy
      audit = record.audits.last

      result = helper.link_to_record_audit( audit )
      expect(result).to match(/A \(example\.com\) 2 destroy by admin/)
    end
  end

  it "should handle records without a 'type' key in the changes hash" do
    domain = FactoryGirl.create(:domain)
    audit = Audit.new(
      :auditable => FactoryGirl.create(:a, :domain => domain),
      :associated => domain,
      :action => 'create',
      :version => 1,
      :user => FactoryGirl.create(:admin),
      :audited_changes => { 'name' => 'example.com' }
    )

    result = helper.link_to_record_audit( audit )
    expect(result).to match(/A \(example\.com\) 1 create by admin/)
  end

  it "should handle removed records without a 'type' key in the changes hash" do
    audit = Audit.new(
      :auditable => nil,
      :associated => FactoryGirl.create(:domain),
      :action => 'destroy',
      :version => 1,
      :user => FactoryGirl.create(:admin),
      :audited_changes => { 'name' => 'local.example.com' }
    )

    result = helper.link_to_record_audit( audit )
    expect(result).to match(/\[UNKNOWN\] \(local\.example\.com\) 1 destroy by admin/)
  end

end

describe AuditsHelper, "audit_user" do

  it "should display user logins if present" do
    audit = Audit.new(
      :auditable => nil,
      :associated => FactoryGirl.create(:domain),
      :action => 'destroy',
      :version => 1,
      :user => FactoryGirl.create(:admin),
      :audited_changes => { 'name' => 'local.example.com' }
    )

    expect(helper.audit_user( audit )).to eq('admin')
  end

  it "should display usernames if present" do
    audit = Audit.new(
      :auditable => nil,
      :associated => FactoryGirl.create(:domain),
      :action => 'destroy',
      :version => 1,
      :username => 'foo',
      :audited_changes => { 'name' => 'local.example.com' }
    )

    expect(helper.audit_user( audit )).to eq('foo')
  end

  it "should not bork on missing user information" do
    audit = Audit.new(
      :auditable => nil,
      :associated => FactoryGirl.create(:domain),
      :action => 'destroy',
      :version => 1,
      :audited_changes => { 'name' => 'local.example.com' }
    )

    expect(helper.audit_user( audit )).to eq('UNKNOWN')
  end
end
