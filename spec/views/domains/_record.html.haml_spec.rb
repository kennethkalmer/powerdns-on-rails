require File.dirname(__FILE__) + '/../../spec_helper'

describe "domains/_record", "for a user" do

  before(:each) do
    template.stubs(:current_user).returns( Factory(:admin) )
    domain = Factory(:domain)
    @record = Factory(:ns, :domain => domain)

    render :partial => 'domains/record', :object => @record
  end

  it "should have tooltips ready" do
    response.should have_tag("div#record-template-edit-#{@record.id}")
    response.should have_tag("div#record-template-delete-#{@record.id}")
  end

  it "should have a marker row (used by AJAX)" do
    response.should have_tag("tr#marker_ns_#{@record.id}")
  end

  it "should have a row with the record details" do
    response.should have_tag("tr#show_ns_#{@record.id}") do
      with_tag("td", "") # shortname
      with_tag("td", "") # ttl
      with_tag("td", "NS") # type
      with_tag("td", "") # prio
      with_tag("td", "ns1.example.com")
    end
  end

  it "should have a row for editing record details" do
    response.should have_tag("tr#edit_ns_#{@record.id}") do
      with_tag("td[colspan=7]") do
        with_tag("form")
      end
    end
  end

  it "should have links to edit/remove the record" do
    response.should have_tag("a[onclick^=editRecord]")
    response.should have_tag("a > img[src*=database_delete]")
  end
end

describe "domains/_record", "for a SLAVE domain" do

  before(:each) do
    template.stubs(:current_user).returns( Factory(:admin) )
    domain = Factory(:domain, :type => 'SLAVE', :master => '127.0.0.1')
    @record = domain.a_records.create( :name => 'foo', :content => '127.0.0.1' )
    render :partial => 'domains/record', :object => @record
  end

  it "should not have tooltips ready" do
    response.should_not have_tag("div#record-template-edit-#{@record.id}")
    response.should_not have_tag("div#record-template-delete-#{@record.id}")
  end

  it "should have a row with the record details" do
    response.should have_tag("tr#show_a_#{@record.id}") do
      with_tag("td", "") # shortname
      with_tag("td", "") # ttl
      with_tag("td", "A") # type
      with_tag("td", "") # prio
      with_tag("td", "foo")
    end
  end

  it "should not have a row for editing record details" do
    response.should_not have_tag("tr#edit_ns_#{@record.id}") do
      with_tag("td[colspan=7]") do
        with_tag("form")
      end
    end
  end

  it "should not have links to edit/remove the record" do
    response.should_not have_tag("a[onclick^=editRecord]")
    response.should_not have_tag("a > img[src*=database_delete]")
  end
end

describe "domains/_record", "for a token" do

  before(:each) do
    @domain = Factory(:domain)
    template.stubs(:current_token).returns( Factory(:auth_token, :domain => @domain, :user => Factory(:admin)) )
  end

  it "should not allow editing NS records" do
    record = Factory(:ns, :domain => @domain)

    render :partial => 'domains/record', :object => record

    response.should_not have_tag("a[onclick^=editRecord]")
    response.should_not have_tag("tr#edit_ns_#{record.id}")
  end

  it "should not allow removing NS records" do
    record = Factory(:ns, :domain => @domain)

    render :partial => 'domains/record', :object => record

    response.should_not have_tag("a > img[src*=database_delete]")
  end

  it "should allow edit records that aren't protected" do
    record = Factory(:a, :domain => @domain)
    render :partial => 'domains/record', :object => record

    response.should have_tag("a[onclick^=editRecord]")
    response.should_not have_tag("a > img[src*=database_delete]")
    response.should have_tag("tr#edit_a_#{record.id}")
  end

  it "should allow removing records if permitted" do
    record = Factory(:a, :domain => @domain)
    token = AuthToken.new(
      :domain => @domain
    )
    token.remove_records=( true )
    token.can_change( record )
    template.stubs(:current_token).returns( token )

    render :partial => 'domains/record', :object => record

    response.should have_tag("a > img[src*=database_delete]")
  end
end
