require File.dirname(__FILE__) + '/../../spec_helper'

describe "macros/edit.html.haml" do
  describe "for new macros" do
    before(:each) do
      assigns[:macro] = Macro.new
      render "macros/edit.html.haml"
    end

    it "should behave accordingly" do
      response.should have_tag('h1', 'New Macro')
    end

  end

  describe "for existing records" do
    before(:each) do
      @macro = Factory(:macro)
      assigns[:macro] = @macro
      render "macros/edit.html.haml"
    end

    it "should behave accordingly" do
      response.should have_tag('h1', 'Update Macro')
    end
  end

  describe "for records with errors" do
    before(:each) do
      assigns[:macro] = Macro.new
      assigns[:macro].valid?
      render "macros/edit.html.haml"
    end

    it "should display the errors" do
      response.should have_tag('div.errorExplanation')
    end
  end
      
end
