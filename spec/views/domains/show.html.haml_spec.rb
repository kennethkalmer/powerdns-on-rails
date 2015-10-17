require 'spec_helper'

describe "domains/show.html.haml" do
  context "for all users" do

    before(:each) do
      view.stubs(:current_user).returns( FactoryGirl.create(:admin) )
      view.stubs(:current_token).returns( nil )
      @domain = FactoryGirl.create(:domain)
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render :template => "/domains/show", :layout => "layouts/application"
    end

    it "should have the domain name in the title and dominant on the page" do
      expect(rendered).to have_tag( "title", :content => "example.com" )
      expect(rendered).to have_tag( "h1", :content => "example.com" )
    end
  end

  context "for admins and domains without owners" do

    before(:each) do
      view.stubs(:current_user).returns( FactoryGirl.create(:admin) )
      view.stubs(:current_token).returns( nil )
      @domain = FactoryGirl.create(:domain)
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render
    end

    it "should display the owner" do
      expect(rendered).to have_tag( "div#owner-info" )
    end

    it "should allow changing the SOA" do
      expect(rendered).to have_tag( "div#soa-form")
    end

    it "should have a form for adding new records" do
      expect(rendered).to have_tag( "div#record-form-div" )
    end

    it "should have not have an additional warnings for removing" do
      expect(rendered).not_to have_tag('div#warning-message')
      expect(rendered).not_to have_tag('a[onclick*=deleteDomain]')
    end
  end

  context "for admins and domains with owners" do

    before(:each) do
      view.stubs(:current_user).returns( FactoryGirl.create(:admin) )
      view.stubs(:current_token).returns( nil )
      @domain = FactoryGirl.create(:domain, :user => FactoryGirl.create(:quentin))
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render
    end

    it "should offer to remove the domain" do
      expect(rendered).to have_tag( "a img[id$=delete-zone]" )
    end

    it "should have have an additional warnings for removing" do
      expect(rendered).to have_tag('div#warning-message')
      expect(rendered).to have_tag('a[onclick*=deleteDomain]')
    end
  end

  context "for owners" do
    before(:each) do
      quentin = FactoryGirl.create(:quentin)
      view.stubs(:current_user).returns( quentin )
      view.stubs(:current_token).returns( nil )

      @domain = FactoryGirl.create(:domain, :user => quentin)
      assign(:domain, @domain)

      render
    end

    it "should display the owner" do
      expect(rendered).not_to have_tag( "div#ownerinfo" )
    end

    it "should allow for changing the SOA" do
      expect(rendered).to have_tag( "div#soa-form" )
    end

    it "should have a form for adding new records" do
      expect(rendered).to have_tag( "div#record-form-div" )
    end

    it "should offer to remove the domain" do
      expect(rendered).to have_tag( "a img[id$=delete-zone]" )
    end

    it "should have not have an additional warnings for removing" do
      expect(rendered).not_to have_tag('div#warning-message')
      expect(rendered).not_to have_tag('a[onclick*=deleteDomain]')
    end
  end

  context "for SLAVE domains" do

    before(:each) do
      view.stubs(:current_user).returns( FactoryGirl.create(:admin) )
      view.stubs(:current_token).returns( nil )

      @domain = FactoryGirl.create(:domain, :type => 'SLAVE', :master => '127.0.0.1')
      assign(:domain, @domain)
      assign(:users, User.active_owners)

      render
    end

    it "should show the master address" do
      expect(rendered).to have_tag('#domain-name td', :content => "Master server")
      expect(rendered).to have_tag('#domain-name td', :content => @domain.master)
    end

    it "should not allow for changing the SOA" do
      expect(rendered).not_to have_tag( "div#soa-form" )
    end

    it "should not have a form for adding new records" do
      expect(rendered).not_to have_tag( "div#record-form-div" )
    end

    it "should offer to remove the domain" do
      expect(rendered).to have_tag( "a img[id$=delete-zone]" )
    end
  end

  context "for token users" do
    before(:each) do
      @admin = FactoryGirl.create(:admin)
      @domain = FactoryGirl.create(:domain)
      assign(:domain, @domain)

      view.stubs(:current_token).returns( FactoryGirl.create(:auth_token, :user => @admin, :domain => @domain) )
      view.stubs(:current_user).returns( nil )
    end

    it "should not offer to remove the domain" do
      render

      expect(rendered).not_to have_tag( "a img[id$=delete-zone]" )
    end

    it "should not offer to edit the SOA" do
      render

      expect(rendered).not_to have_tag( "a[onclick^=showSOAEdit]")
      expect(rendered).not_to have_tag( "div#soa-form" )
    end

    it "should only allow new record if permitted (FALSE)" do
      render

      expect(rendered).not_to have_tag( "div#record-form-div" )
    end

    it "should only allow new records if permitted (TRUE)" do
      token = AuthToken.new(
        :domain => @domain
      )
      token.allow_new_records=( true )
      view.stubs(:current_token).returns( token )
      render

      expect(rendered).to have_tag( "div#record-form-div" )
    end
  end
end
