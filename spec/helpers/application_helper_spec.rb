require 'spec_helper'

describe ApplicationHelper do
  describe "link_to_cancel" do
    it "on new records should link to index" do
      html = helper.link_to_cancel( Macro.new )
      expect(html).to have_tag('a[href="/macros"]', :content => 'Cancel')
    end

    it "on existing records should link to show" do
      macro = FactoryGirl.create(:macro)
      html = helper.link_to_cancel( macro )
      expect(html).to have_tag("a[href='/macros/#{macro.id}']", :content => 'Cancel')
    end
  end

end
