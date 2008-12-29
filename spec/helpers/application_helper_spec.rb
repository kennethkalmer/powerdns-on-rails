require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  describe "link_to_cancel" do
    it "on new records should link to index" do
      html = helper.link_to_cancel( Macro.new )
      html.should have_tag('a[href=/macros]', 'Cancel')
    end

    it "on existing records should link to show" do
      macro = Factory(:macro)
      html = helper.link_to_cancel( macro )
      html.should have_tag("a[href=/macros/#{macro.id}]", 'Cancel')
    end
  end
  
end
