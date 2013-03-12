require 'spec_helper'

describe "domains/_record" do
  context "for a user" do

    before(:each) do
      view.stubs(:current_user).returns( Factory(:admin) )
      domain = Factory(:domain)
      @record = Factory(:ns, :domain => domain)

      render :partial => 'domains/record', :object => @record
    end

    it "should have a marker row (used by AJAX)" do
      rendered.should have_tag("tr#marker_ns_#{@record.id}")
    end

    it "should have a row with the record details" do
      rendered.should have_tag("tr#show_ns_#{@record.id} > td", :content => "") # shortname
      rendered.should have_tag("tr#show_ns_#{@record.id} > td", :content => "") # ttl
      rendered.should have_tag("tr#show_ns_#{@record.id} > td", :content => "NS") # shortname
      rendered.should have_tag("tr#show_ns_#{@record.id} > td", :content => "") # prio
      rendered.should have_tag("tr#show_ns_#{@record.id} > td", :content => "ns1.example.com")
    end

    it "should have a row for editing record details" do
      rendered.should have_tag("tr#edit_ns_#{@record.id} > td[colspan='7'] > form")
    end

    it "should have links to edit/remove the record" do
      rendered.should have_tag("a[onclick^=editRecord]")
      rendered.should have_tag("a > img[src*=database_delete]")
    end
  end

  context "for a SLAVE domain" do

    before(:each) do
      view.stubs(:current_user).returns( Factory(:admin) )
      domain = Factory(:domain, :type => 'SLAVE', :master => '127.0.0.1')
      @record = domain.a_records.create( :name => 'foo', :content => '127.0.0.1' )
      render :partial => 'domains/record', :object => @record
    end

    it "should not have tooltips ready" do
      rendered.should_not have_tag("div#record-template-edit-#{@record.id}")
      rendered.should_not have_tag("div#record-template-delete-#{@record.id}")
    end

    it "should have a row with the record details" do
      rendered.should have_tag("tr#show_a_#{@record.id} > td", :content => "") # shortname
      rendered.should have_tag("tr#show_a_#{@record.id} > td", :content => "") # ttl
      rendered.should have_tag("tr#show_a_#{@record.id} > td", :content => "A")
      rendered.should have_tag("tr#show_a_#{@record.id} > td", :content => "") # prio
      rendered.should have_tag("tr#show_a_#{@record.id} > td", :content => "foo")
    end

    it "should not have a row for editing record details" do
      rendered.should_not have_tag("tr#edit_ns_#{@record.id} > td[colspan='7'] > form")
    end

    it "should not have links to edit/remove the record" do
      rendered.should_not have_tag("a[onclick^=editRecord]")
      rendered.should_not have_tag("a > img[src*=database_delete]")
    end
  end

  context "for a token" do

    before(:each) do
      @domain = Factory(:domain)
      view.stubs(:current_user).returns( nil )
      view.stubs(:current_token).returns( Factory(:auth_token, :domain => @domain, :user => Factory(:admin)) )
    end

    it "should not allow editing NS records" do
      record = Factory(:ns, :domain => @domain)

      render :partial => 'domains/record', :object => record

      rendered.should_not have_tag("a[onclick^=editRecord]")
      rendered.should_not have_tag("tr#edit_ns_#{record.id}")
    end

    it "should not allow removing NS records" do
      record = Factory(:ns, :domain => @domain)

      render :partial => 'domains/record', :object => record

      rendered.should_not have_tag("a > img[src*=database_delete]")
    end

    it "should allow edit records that aren't protected" do
      record = Factory(:a, :domain => @domain)
      render :partial => 'domains/record', :object => record

      rendered.should have_tag("a[onclick^=editRecord]")
      rendered.should_not have_tag("a > img[src*=database_delete]")
      rendered.should have_tag("tr#edit_a_#{record.id}")
    end

    it "should allow removing records if permitted" do
      record = Factory(:a, :domain => @domain)
      token = AuthToken.new(
        :domain => @domain
      )
      token.remove_records=( true )
      token.can_change( record )
      view.stubs(:current_token).returns( token )

      render :partial => 'domains/record', :object => record

      rendered.should have_tag("a > img[src*=database_delete]")
    end
  end
end
