require File.dirname(__FILE__) + '/../../spec_helper'

describe "macros/index.html.haml" do

  it "should render a list of macros" do
    2.times { |i| Factory(:macro, :name => "Macro #{i}") }
    assigns[:macros] = Macro.find(:all)

    render 'macros/index.html.haml'

    response.should have_tag('h1', 'Macros')
    response.should have_tag('table') do
      with_tag('a[href^=/macro]')
    end
  end

  it "should indicate no macros are present" do
    assigns[:macros] = Macro.find(:all)

    render 'macros/index.html.haml'

    response.should have_tag('em', /don't have any macros/)
  end
  
end
