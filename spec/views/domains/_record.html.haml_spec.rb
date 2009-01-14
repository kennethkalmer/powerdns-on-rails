require File.dirname(__FILE__) + '/../../spec_helper'

describe "domains/_record", "for a user" do
  fixtures :users, :records
  
  before(:each) do
    template.stubs(:current_user).returns( users(:admin) )
    @record = records(:example_com_ns_ns1)
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

describe "domains/_record", "for a token" do
  fixtures :auth_tokens, :records, :domains
  
  it "should not allow editing NS records" do
    template.stubs(:current_token).returns( auth_tokens(:token_example_com) )
    record = records(:example_com_ns_ns1)
    render :partial => 'domains/record', :object => record
    
    response.should_not have_tag("a[onclick^=editRecord]")
    response.should_not have_tag("tr#edit_ns_#{record.id}")
  end
  
  it "should not allow removing NS records" do
    template.stubs(:current_token).returns( auth_tokens(:token_example_com) )
    record = records(:example_com_ns_ns1)
    render :partial => 'domains/record', :object => record
    
    response.should_not have_tag("a > img[src*=database_delete]")
  end
  
  it "should allow edit records that aren't protected" do
    template.stubs(:current_token).returns( auth_tokens(:token_example_com) )
    record = records(:example_com_a)
    render :partial => 'domains/record', :object => record
    
    response.should have_tag("a[onclick^=editRecord]")
    response.should_not have_tag("a > img[src*=database_delete]")
    response.should have_tag("tr#edit_a_#{record.id}")
  end
  
  it "should allow removing records if permitted" do
    record = records(:example_com_a)
    token = AuthToken.new(
      :domain => domains(:example_com)
    )
    token.remove_records=( true )
    token.can_change( record )
    template.stubs(:current_token).returns( token )
    render :partial => 'domains/record', :object => record
    
    response.should have_tag("a > img[src*=database_delete]")
  end
end
