require File.dirname(__FILE__) + '/../../spec_helper'

describe "templates/show.html.haml", "for complete templates" do

  before(:each) do
    @zone_template = Factory(:zone_template)
    Factory(:template_soa, :zone_template => @zone_template)
    assigns[:zone_template] = @zone_template
    assigns[:record_template] = RecordTemplate.new( :record_type => 'A' )

    render "templates/show.html.haml"
  end

  it "should have the template name" do
    response.should have_tag('h1', /^#{@zone_template.name}/)
  end

  it "should have a table with template overview" do
    response.should have_tag('table.grid') do
      with_tag('td', 'Name')
      with_tag('td', 'TTL')
    end
  end

  it "should have the record templates" do
    response.should have_tag('h1', 'Record templates')
    response.should have_tag('table#record-table')
  end

  it "should not have an SOA warning" do
    violated "ZoneTemplate does not have SOA" unless @zone_template.has_soa?

    response.should_not have_tag('div#soa-warning')
  end

end

describe "templates/show.html.haml", "for partial templates" do
  before(:each) do
    @zone_template = Factory(:zone_template)
    assigns[:zone_template] = @zone_template
    assigns[:record_template] = RecordTemplate.new( :record_type => 'A' )

    render "templates/show.html.haml"
  end

  it "should have an SOA warning" do
    response.should have_tag('div#soa-warning')
  end

end

