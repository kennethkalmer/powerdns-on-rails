require 'spec_helper'

describe "templates/new.html.haml" do

  context "and new templates" do
    before(:each) do
      assign(:zone_template, ZoneTemplate.new)
    end

    it "should have a list of users if provided" do
      Factory(:quentin)

      render

      rendered.should have_tag('select#zone_template_user_id')
    end

    it "should render without a list of users" do
      render

      rendered.should_not have_tag('select#zone_template_user_id')
    end

    it "should render with a missing list of users (nil)" do
      render

      rendered.should_not have_tag('select#zone_template_user_id')
    end

    it "should show the correct title" do
      render

      rendered.should have_tag('h1.underline', :content => 'New Zone Template')
    end
  end

end
