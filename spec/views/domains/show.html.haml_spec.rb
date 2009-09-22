require File.dirname(__FILE__) + '/../../spec_helper'

describe "domain/show.html.haml", "for all users" do

  before(:each) do
    template.stubs(:current_user).returns( Factory(:admin) )
    @domain = Factory(:domain)
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

  before(:each) do
    template.stubs(:current_user).returns( Factory(:admin) )
    @domain = Factory(:domain)
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

  before(:each) do
    template.stubs(:current_user).returns( Factory(:admin) )
    @domain = Factory(:domain, :user => Factory(:quentin))
    assigns[:domain] = @domain
    assigns[:record] = @domain.records.new
    assigns[:users] = User.active_owners

    render "/domains/show.html.haml"
  end

  it "should offer to remove the domain" do
    response.should have_tag( "a img[id$=delete-zone]" )
  end

  it "should have have an additional warnings for removing" do
    response.should have_tag('div#warning-message')
    response.should have_tag('a[onclick*=deleteDomain]')
  end
end

describe "domain/show.html.haml", "for owners" do
  before(:each) do
    quentin = Factory(:quentin)
    template.stubs(:current_user).returns( quentin )
    @domain = Factory(:domain, :user => quentin)
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

  it "should offer to remove the domain" do
    response.should have_tag( "a img[id$=delete-zone]" )
  end

  it "should have not have an additional warnings for removing" do
    response.should_not have_tag('div#warning-message')
    response.should_not have_tag('a[onclick*=deleteDomain]')
  end
end

describe "domain/show.html.haml", "for SLAVE domains" do

  before(:each) do
    template.stubs(:current_user).returns( Factory(:admin) )
    @domain = Factory(:domain, :type => 'SLAVE', :master => '127.0.0.1')
    assigns[:domain] = @domain
    assigns[:users] = User.active_owners

    render "domains/show.html.haml"
  end

  it "should show the master address" do
    response.should have_tag('table.grid') do
      with_tag "td", "Master server"
      with_tag "td", @domain.master
    end
  end

  it "should not allow for changing the SOA" do
    response.should_not have_tag( "div#soa-edit-form" )
  end

  it "should not have a form for adding new records" do
    response.should_not have_tag( "div#record-form-div" )
  end

  it "should offer to remove the domain" do
    response.should have_tag( "a img[id$=delete-zone]" )
  end
end

describe "domain/show.html.haml", "for token users" do
  before(:each) do
    @admin = Factory(:admin)
    @domain = Factory(:domain)
    assigns[:domain] = @domain
    assigns[:record] = @domain.records.new
    template.stubs(:current_token).returns( Factory(:auth_token, :user => @admin, :domain => @domain) )
  end

  it "should not offer to remove the domain" do
    render "domains/show.html.haml"

    response.should_not have_tag( "a img[id$=delete-zone]" )
  end

  it "should not offer to edit the SOA" do
    render "domains/show.html.haml"

    response.should_not have_tag( "a[onclick^=showSOAEdit]")
    response.should_not have_tag( "div#soa-edit-form" )
  end

  it "should only allow new record if permitted (FALSE)" do
    render "domains/show.html.haml"

    response.should_not have_tag( "div#record-form-div" )
  end

  it "should only allow new records if permitted (TRUE)" do
    token = AuthToken.new(
      :domain => @domain
    )
    token.allow_new_records=( true )
    template.stubs(:current_token).returns( token )
    render "domains/show.html.haml"

    response.should have_tag( "div#record-form-div" )
  end
end
