require 'spec_helper'

describe "templates/new.html.haml" do

  context "and new templates" do
    before(:each) do
      assign(:zone_template, ZoneTemplate.new)
    end

    it "should have a list of users if provided" do
      FactoryGirl.create(:quentin)

      render

      expect(rendered).to have_tag('select#zone_template_user_id')
    end

    it "should render without a list of users" do
      render

      expect(rendered).not_to have_tag('select#zone_template_user_id')
    end

    it "should render with a missing list of users (nil)" do
      render

      expect(rendered).not_to have_tag('select#zone_template_user_id')
    end

    it "should show the correct title" do
      render

      expect(rendered).to have_tag('h1.underline', :content => 'New Zone Template')
    end
  end

end
