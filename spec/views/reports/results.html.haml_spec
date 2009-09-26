require File.dirname(__FILE__) + '/../../spec_helper'

describe "/reports/results" do

  before(:each) do
    @admin = Factory(:admin)
  end

  it "should handle no results" do
    assigns[:results] = []

    render "/reports/results"

    response.should have_tag("strong", "No users found")
  end

  it "should handle results within the pagination limit" do
    assigns[:results] = User.search( 'a', 1 )

    render "/reports/results"

    response.should have_tag("table") do
      with_tag "a", "admin"
    end
  end

  it "should handle results with pagination and scoping" do
    1.upto(100) do |i|
      user = User.new
      user.login = "test-user-#{i}"
      user.save( false ).should be_true
    end

    assigns[:results] = User.search( 'test-user', 1 )

    render "/reports/results"

    response.should have_tag("table") do
      with_tag "a", "test-user-1"
    end
  end

end
