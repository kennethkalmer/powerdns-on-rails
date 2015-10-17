require 'spec_helper'

describe "macros/edit.html.haml" do
  before(:each) do
    admin = FactoryGirl.build_stubbed( :admin )
    allow(view).to receive( :current_user ).and_return( admin )
  end

  context "for new macros" do
    before(:each) do
      assign(:macro, Macro.new)
      render
    end

    it "should behave accordingly" do
      expect(rendered).to have_tag('h1', :content => 'New Macro')
    end

  end

  context "for existing records" do
    before(:each) do
      @macro = FactoryGirl.create(:macro)
      assign(:macro, @macro)
      render
    end

    it "should behave accordingly" do
      expect(rendered).to have_tag('h1', :content => 'Update Macro')
    end
  end

  describe "for records with errors" do
    before(:each) do
      m = Macro.new
      m.valid?
      assign(:macro, m)
      render
    end

    it "should display the errors" do
      expect(rendered).to have_tag('div.errorExplanation')
    end
  end

end
