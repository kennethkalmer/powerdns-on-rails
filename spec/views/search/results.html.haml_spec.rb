require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/results" do

  before(:each) do
    @admin = Factory(:admin)
    template.stubs(:current_user).returns(@admin)
  end

  it "should handle no results" do
    assigns[:results] = []

    render "/search/results"

    response.should have_tag("strong", "No domains found")
  end

  it "should handle results within the pagination limit" do
    1.upto(4) do |i|
      zone = Domain.new
      zone.id = i
      zone.name = "zone-#{i}.com"
      zone.save( false ).should be_true
    end

    assigns[:results] = Domain.search( 'zone', 1, @admin )

    render "/search/results"

    response.should have_tag("table") do
      with_tag "a", "zone-1.com"
    end
  end

  it "should handle results with pagination and scoping" do
    1.upto(100) do |i|
      zone = Domain.new
      zone.id = i
      zone.name = "domain-#{i}.com"
      zone.save( false ).should be_true
    end

    assigns[:results] = Domain.search( 'domain', 1, @admin )

    render "/search/results"

    response.should have_tag("table") do
      with_tag "a", "domain-1.com"
    end
  end

end
