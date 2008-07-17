require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/results" do
  
  before(:each) do
    @admin = User.new
    @admin.stubs(:has_role?).with('admin').returns(true)
  end
  
  it "should handle no results" do
    assigns[:results] = []
    
    render "/search/results"
    
    response.should have_tag("strong", "No zones found")
  end
  
  it "should handle results within the pagination limit" do
    1.upto(4) do |i|
      zone = Zone.new
      zone.id = i
      zone.name = "zone-#{i}.com"
      zone.save( false ).should be_true
    end
    
    assigns[:results] = Zone.search( 'zone', 1, @admin )
    
    render "/search/results"
    
    response.should have_tag("table") do
      with_tag "a", "zone-1.com"
    end
  end
  
  it "should handle results with pagination and scoping" do
    1.upto(100) do |i|
      zone = Zone.new
      zone.id = i
      zone.name = "zone-#{i}.com"
      zone.save( false ).should be_true
    end
    
    assigns[:results] = Zone.search( 'zone', 1, @admin )
    
    render "/search/results"
    
    response.should have_tag("table") do
      with_tag "a", "zone-1.com"
    end
  end
  
end