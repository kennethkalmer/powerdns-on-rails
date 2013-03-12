require 'spec_helper'

describe "macros/edit.html.haml" do
  context "for new macros" do
    before(:each) do
      assign(:macro, Macro.new)
      render
    end

    it "should behave accordingly" do
      rendered.should have_tag('h1', :content => 'New Macro')
    end

  end

  context "for existing records" do
    before(:each) do
      @macro = Factory(:macro)
      assign(:macro, @macro)
      render
    end

    it "should behave accordingly" do
      rendered.should have_tag('h1', :content => 'Update Macro')
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
      rendered.should have_tag('div.errorExplanation')
    end
  end

end
