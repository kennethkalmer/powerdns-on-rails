require File.dirname(__FILE__) + '/../../spec_helper'

describe "domain/show.html.haml", "for all users" do
  fixtures :all
  
  before(:each) do
    template.stubs(:current_user).returns( users(:admin) )
    @domain = domains(:example_com)
    assigns[:domain] = @domain
    assigns[:record] = @domain.records.new
    assigns[:users] = User.active_owners
    
    render "/domains/show.html.haml", :layout => true
  end
  
  it "should have the domain name in the title and dominant on the page" do
    response.should have_tag( "title", /example\.com/ )
    response.should have_tag( "h1", /example\.com/ )
  end
end

describe "domain/show.html.haml", "for admins and domains without owners" do
  fixtures :all
  
  before(:each) do
    template.stubs(:current_user).returns( users(:admin) )
    @domain = domains(:example_com)
    assigns[:domain] = @domain
    assigns[:record] = @domain.records.new
    assigns[:users] = User.active_owners
    
    render "/domains/show.html.haml"
  end
  
  it "should display the owner" do
    response.should have_tag( "div#owner-info" )
  end
  
  it "should allow changing the SOA" do
    response.should have_tag( "div#soa-edit-form")
  end
  
  it "should have a form for adding new records" do
    response.should have_tag( "div#record-form-div" )
  end
  
  it "should have not have an additional warnings for removing" do
    response.should_not have_tag('div#warning-message')
    response.should_not have_tag('a[onclick*=deleteDomain]')
  end
end

describe "domain/show", "for admins and domains with owners" do
  fixtures :all
  
  before(:each) do
    template.stubs(:current_user).returns( users(:admin) )
    @domain = domains(:example_net)
    assigns[:domain] = @domain
    assigns[:record] = @domain.records.new
    assigns[:users] = User.active_owners
    
    render "/domains/show.html.haml"
  end
  
  it "should have have an additional warnings for removing" do
    response.should have_tag('div#warning-message')
    response.should have_tag('a[onclick*=deleteDomain]')
  end
end

describe "domain/show.html.haml", "for owners" do
  fixtures :all
  
  before(:each) do
    template.stubs(:current_user).returns( users(:quentin) )
    @domain = domains(:example_net)
    assigns[:domain] = @domain
    assigns[:record] = @domain.records.new
    
    render "/domains/show.html.haml"
  end
  
  it "should display the owner" do
    response.should_not have_tag( "div#ownerinfo" )
  end
  
  it "should allow for changing the SOA" do
    response.should have_tag( "div#soa-edit-form" )
  end
  
  it "should have a form for adding new records" do
    response.should have_tag( "div#record-form-div" )
  end
  
  it "should have not have an additional warnings for removing" do
    response.should_not have_tag('div#warning-message')
    response.should_not have_tag('a[onclick*=deleteDomain]')
  end
end

describe "domain/show.html.haml", "for token users" do
  fixtures :auth_tokens, :domains, :records
  
  before(:each) do
    @domain = domains(:example_com)
    assigns[:domain] = @domain
    assigns[:record] = @domain.records.new
  end
  
  it "should not offer to edit the SOA" do
    template.stubs(:current_token).returns( auth_tokens(:token_example_com) )
    render "domains/show.html.haml"
    
    response.should_not have_tag( "a[onclick^=showSOAEdit]")
    response.should_not have_tag( "div#soa-edit-form" )
  end
  
  it "should only allow new record if permitted (FALSE)" do
    template.stubs(:current_token).returns( auth_tokens(:token_example_com) )
    render "domains/show.html.haml"
    
    response.should_not have_tag( "div#record-form-div" )
  end
  
  it "should only allow new records if permitted (TRUE)" do
    token = AuthToken.new(
      :domain => domains(:example_com)
    )
    token.allow_new_records=( true )
    template.stubs(:current_token).returns( token )
    render "domains/show.html.haml"
    
    response.should have_tag( "div#record-form-div" )
  end
end
