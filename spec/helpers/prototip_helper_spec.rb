require File.dirname(__FILE__) + '/../spec_helper'

describe PrototipHelper do
  describe "prototip_help_icon" do
    before(:each) do
      @html = helper.prototip_help_icon( 'test' )
    end

    it "should have a help icon" do
      @html.should have_tag('img[src^=/images/help.png]')
    end

    it "should have javascript to display the tooltip" do
      @html.should have_tag('script', /new Tip/)
    end
  end

  describe "prototip_info_icon" do
    before(:each) do
      @html = helper.prototip_info_icon( 'database_add.png', 'test')
    end

    it "should have our custom image" do
      @html.should have_tag('img[src^=/images/database_add.png]')
    end

    it "should have javascript to display the tooltip" do
      @html.should have_tag('script', /new Tip/)
    end
    
  end
  
end
