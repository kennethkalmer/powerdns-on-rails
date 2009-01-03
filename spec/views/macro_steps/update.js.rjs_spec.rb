require File.dirname(__FILE__) + '/../../spec_helper'

describe "macro_steps/update.js.rjs" do
  before(:each) do
    assigns[:macro] = @macro = Factory(:macro)
    assigns[:macro_step] = @macro_step = Factory(:macro_step_create, :macro => @macro)
  end

  describe "for valid updates" do

    before(:each) do
      render "macro_steps/update.js.rjs"
    end
    
    it "should display a notice" do
      response.should include_text(%{showflash("info"})
    end
    
    it "should update the steps table" do
      response.should have_rjs(:remove, "show_macro_step_#{@macro_step.id}")
      response.should have_rjs(:remove, "edit_macro_step_#{@macro_step.id}")
      response.should have_rjs(:replace, "marker_macro_step_#{@macro_step.id}")
    end
      
  end

  describe "for invalid updates" do

    before(:each) do
      assigns[:macro_step].content = ''
      assigns[:macro_step].valid?

      render "macro_steps/update.js.rjs"
    end
      
   
    it "should display an error" do
      response.should have_rjs(:replace_html, "error_macro_step_#{@macro_step.id}")
    end
    
  end
end

