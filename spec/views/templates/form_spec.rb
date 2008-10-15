require File.dirname(__FILE__) + '/../../spec_helper'

describe "/templates/form" do
  
  it "should have a list of users if provided" do
    u = User.new( :login => 'test' )
    u.id = 1
    
    assigns[:users] = [ u ]
    assigns[:zone_template] = ZoneTemplate.new
    
    render "/templates/form"
    
    response.should have_tag('select#zone_template_user_id')
  end
  
  it "should render without a list of users" do
    assigns[:zone_template] = ZoneTemplate.new
    assigns[:users] = []
    
    render "/templates/form"
    
    response.should_not have_tag('select#zone_template_user_id')
  end
end
