require 'spec_helper'

describe "templates/show.html.haml" do
  context "for complete templates" do
    before(:each) do
      @zone_template = FactoryGirl.create(:zone_template)
      FactoryGirl.create(:template_soa, :zone_template => @zone_template)

      assign(:zone_template, @zone_template)
      assign(:record_template, RecordTemplate.new( :record_type => 'A' ))

      render
    end

    it "should have the template name" do
      expect(rendered).to have_tag('h1', :content => @zone_template.name)
    end

    it "should have a table with template overview" do
      expect(rendered).to have_selector('table.grid td', :content => 'Name')
      expect(rendered).to have_selector('table.grid td', :content => 'TTL')
    end

    it "should have the record templates" do
      expect(rendered).to have_selector('h1', :content => 'Record templates')
      expect(rendered).to have_selector('table#record-table')
    end

    it "should not have an SOA warning" do
      violated "ZoneTemplate does not have SOA" unless @zone_template.has_soa?

      expect(rendered).not_to have_selector('div#soa-warning')
    end
  end


  context "for partial templates" do
    before(:each) do
      @zone_template = FactoryGirl.create(:zone_template)
      assign(:zone_template, @zone_template)
      assign(:record_template, RecordTemplate.new( :record_type => 'A' ))

      render
    end

    it "should have an SOA warning" do
      expect(rendered).to have_tag('div#soa-warning')
    end

  end
end
