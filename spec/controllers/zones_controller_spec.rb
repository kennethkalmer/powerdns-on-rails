require File.dirname(__FILE__) + '/../spec_helper'

describe ZonesController, "index" do
  fixtures :all
  
  it "should display all zones to the admin" do
    session[:user_id] = users( :admin ).id
    
    get 'index'
    
    response.should render_template('zones/index')
    assigns[:zones].should_not be_empty
    assigns[:zones].size.should be(2)
  end
  
  it "should restrict zones for owners" do
    session[:user_id] = users( :quentin ).id
    
    get 'index'
    
    response.should render_template('zones/index')
    assigns[:zones].should_not be_empty
    assigns[:zones].size.should be(1)
  end
end

describe ZonesController, "when creating" do
  fixtures :all
  
  before(:each) do
    session[:user_id] = users( :admin ).id
  end
  
  it "should have a form for adding a new zone" do
    get 'new'
    
    response.should render_template('zones/new')
    assigns[:zone].should be_a_kind_of( Zone )
    assigns[:zone_templates].should_not be_empty
  end
  
  it "should not save a partial form" do
    post 'create', :zone => { :name => 'example.org' }
    
    response.should_not be_redirect
    response.should render_template('zones/new')
    assigns[:zone_templates].should_not be_empty
  end
  
  it "should be redirected to the zone details after a successful save" do
    post 'create', :zone => { 
      :name => 'example.org', :primary_ns => 'ns1.example.org', 
      :contact => 'admin.example.org', :refresh => 10800, :retry => 7200,
      :expire => 604800, :minimum => 10800
    }
    
    response.should be_redirect
    response.should redirect_to( zone_path( assigns[:zone] ) )
    flash[:info].should_not be_nil
  end
  
  it "should offer to create templates if none are found" do
    
  end
  
end