require 'spec_helper'

describe "templates/edit.html.haml" do

  context "and existing templates" do

    before(:each) do
      @zone_template = FactoryGirl.create(:zone_template)
      assign(:zone_template, @zone_template)
    end

    it "should show the correct title" do
      render

      expect(rendered).to have_tag('h1.underline', :content => 'Update Zone Template')
    end
  end

end
