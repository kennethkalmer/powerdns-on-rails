require File.dirname(__FILE__) + '/../../spec_helper'

describe "macro_steps/create.js.rjs" do
  describe "for failed records" do
    before(:each) do
      assigns[:macro] = Factory.build(:macro)
      assigns[:macro_step] = MacroStep.new
      assigns[:macro_step].valid?

      render('macro_steps/create.js.rjs')
    end

    it "should insert errors into the page" do
      response.should have_rjs(:replace_html, 'record-form-error')
    end

    it "should have a error flash" do
      response.should include_text(%{showflash("error"})
    end
  end

  describe "for successful records" do
    before(:each) do
      assigns[:macro] = Factory(:macro)
      assigns[:macro_step] = Factory(:macro_step_create, :macro => assigns[:macro])

      render('macro_steps/create.js.rjs')
    end

    it "should display a notice flash" do
      response.should include_text(%{showflash("info"} )
    end

    it "should insert the steps into the table" do
      response.should have_rjs(:insert, :bottom, 'steps-table')
    end

  end

end
