require File.dirname(__FILE__) + '/../spec_helper'

describe AuditsHelper, "display_hash" do
  
  it "should handle a blank changes hash" do
    helper.display_hash( nil ).should eql('')
  end
  
  it "should have a way to display the changes hash with blank stipped" do
    result = helper.display_hash( 'key' => 'value', :blank => nil )
    result.should eql("<em>key</em>: value")
  end
  
  it "should seperate items in the change hash with breaks" do
    result = helper.display_hash( 'one' => 'one', 'two' => 'two' )
    result.should eql("<em>two</em>: two<br /><em>one</em>: one")
  end
  
end

describe AuditsHelper, "link_to_domain_audit" do
  fixtures :users, :domains, :audits
  
  it "should handle an existing domain & existing user" do
    audit = Audit.new(
      :auditable => domains(:example_com),
      :version => 1,
      :action => 'create',
      :user => users(:admin)
    )
    
    results = helper.link_to_domain_audit( audit )
    
    results.should match(/1 create by admin/)
  end
  
  it "should handle existing domains & removed users" do
    audit = Audit.new(
      :auditable => domains(:example_com),
      :version => 1,
      :action => 'create',
      :user => 'admin'
    )
    
    results = helper.link_to_domain_audit( audit )
    
    results.should match(/1 create by admin/)
  end
  
  it "should handle removed domains & existing users" do
    audit = Audit.new(
      :auditable => nil,
      :version => 1,
      :action => 'destroy',
      :user => users(:admin),
      :changes => { 'name' => 'example.net' }
    )
    
    results = helper.link_to_domain_audit( audit )
    
    results.should match(/1 destroy by admin/)
  end
  
  it "should handle removed domains & removed users" do
    audit = Audit.new(
      :auditable => nil,
      :version => 1,
      :action => 'destroy',
      :user => 'admin',
      :changes => { 'name' => 'example.net' }
    )
    
    results = helper.link_to_domain_audit( audit )
    
    results.should match(/1 destroy by admin/)
  end
  
end

describe AuditsHelper, "link_to_record_audit" do
  fixtures :users, :domains, :audits, :records
  
  it "should handle an existing record & existing user" do
    audit = Audit.new(
      :auditable => records(:example_com_a),
      :auditable_parent => domains(:example_com),
      :action => 'create',
      :version => 1,
      :user => users(:admin),
      :changes => { 'type' => 'A', 'name' => 'example.com' }
    )
    
    result = helper.link_to_record_audit( audit )
    result.should match(/A \(example\.com\) 1 create by admin/)
  end
  
  it "should handle existing records & removed users" do
    audit = Audit.new(
      :auditable => records(:example_com_a),
      :auditable_parent => domains(:example_com),
      :action => 'create',
      :version => 1,
      :user => 'admin',
      :changes => { 'type' => 'A', 'name' => 'example.com' }
    )
    
    result = helper.link_to_record_audit( audit )
    result.should match(/A \(example\.com\) 1 create by admin/)
  end
  
  it "should handle removed records & existing users" do
    audit = Audit.new(
      :auditable => nil,
      :auditable_parent => domains(:example_com),
      :action => 'destroy',
      :version => 1,
      :user => users(:admin),
      :changes => { 'type' => 'A', 'name' => 'local.example.com' }
    )
    
    result = helper.link_to_record_audit( audit )
    result.should match(/A \(local\.example\.com\) 1 destroy by admin/)
  end
  
  it "should handle removed records & removed users" do
    audit = Audit.new(
      :auditable => nil,
      :auditable_parent => domains(:example_com),
      :action => 'destroy',
      :version => 1,
      :user => 'admin',
      :changes => { 'type' => 'A', 'name' => 'local.example.com' }
    )
    
    result = helper.link_to_record_audit( audit )
    result.should match(/A \(local\.example\.com\) 1 destroy by admin/)
  end
  
  it "should handle records without a 'type' key in the changes hash" do
    audit = Audit.new(
      :auditable => records(:example_com_a),
      :auditable_parent => domains(:example_com),
      :action => 'create',
      :version => 1,
      :user => users(:admin),
      :changes => { 'name' => 'example.com' }
    )
    
    result = helper.link_to_record_audit( audit )
    result.should match(/A \(example\.com\) 1 create by admin/)
  end
  
  it "should handle removed records without a 'type' key in the changes hash" do
    audit = Audit.new(
      :auditable => nil,
      :auditable_parent => domains(:example_com),
      :action => 'destroy',
      :version => 1,
      :user => users(:admin),
      :changes => { 'name' => 'local.example.com' }
    )
    
    result = helper.link_to_record_audit( audit )
    result.should match(/\[UNKNOWN\] \(local\.example\.com\) 1 destroy by admin/)
  end
  
end

describe AuditsHelper, "audit_user" do
  fixtures :all

  it "should display user logins if present" do
    audit = Audit.new(
      :auditable => nil,
      :auditable_parent => domains(:example_com),
      :action => 'destroy',
      :version => 1,
      :user => users(:admin),
      :changes => { 'name' => 'local.example.com' }
    )

    helper.audit_user( audit ).should == users(:admin).login
  end

  it "should display usernames if present" do
    audit = Audit.new(
      :auditable => nil,
      :auditable_parent => domains(:example_com),
      :action => 'destroy',
      :version => 1,
      :username => 'foo',
      :changes => { 'name' => 'local.example.com' }
    )

    helper.audit_user( audit ).should == 'foo'
  end

  it "should not bork on missing user information" do
    audit = Audit.new(
      :auditable => nil,
      :auditable_parent => domains(:example_com),
      :action => 'destroy',
      :version => 1,
      :changes => { 'name' => 'local.example.com' }
    )


    helper.audit_user( audit ).should == 'UNKNOWN'
  end
end
