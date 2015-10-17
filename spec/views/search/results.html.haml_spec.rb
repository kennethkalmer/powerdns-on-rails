require 'spec_helper'

describe "search/results.html.haml" do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    view.stubs(:current_user).returns(@admin)
    view.stubs(:current_token).returns(nil)
  end

  it "should handle no results" do
    assign(:results, [])

    render

    expect(rendered).to have_tag("strong", :content => "No domains found")
  end

  it "should handle results within the pagination limit" do
    1.upto(4) do |i|
      zone = Domain.new
      zone.id = i
      zone.name = "zone-#{i}.com"
      expect(zone.save( :validate => false )).to be_truthy
    end

    assign(:results, Domain.search( 'zone', 1, @admin ))

    render 

    expect(rendered).to have_tag("table a", :content => "zone-1.com")
  end

  it "should handle results with pagination and scoping" do
    1.upto(100) do |i|
      zone = Domain.new
      zone.id = i
      zone.name = "domain-#{i}.com"
      expect(zone.save( :validate => false )).to be_truthy
    end

    assign(:results, Domain.search( 'domain', 1, @admin ))

    render

    expect(rendered).to have_tag("table a", :content => "domain-1.com")
  end

end
