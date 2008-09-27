require File.dirname(__FILE__) + '/../spec_helper'

include AuthenticatedTestHelper

describe DomainsController, "index" do
  fixtures :all
  
  it "should display all zones to the admin" do
    login_as(:admin)
    
    get 'index'
    
    response.should render_template('domains/index')
    assigns[:domains].should_not be_empty
    assigns[:domains].size.should be(2)
  end
  
  it "should restrict zones for owners" do
    login_as( :quentin )
    
    get 'index'
    
    response.should render_template('domains/index')
    assigns[:domains].should_not be_empty
    assigns[:domains].size.should be(1)
  end
end

describe DomainsController, "when creating" do
  fixtures :all
  
  before(:each) do
    login_as(:admin)
  end
  
  it "should have a form for adding a new zone" do
    get 'new'
    
    response.should render_template('domains/new')
    assigns[:domain].should be_a_kind_of( Domain )
    assigns[:zone_templates].should_not be_empty
    assigns[:zone_templates].size.should be(3)
  end
  
  it "should not save a partial form" do
    post 'create', :domain => { :name => 'example.org' }, :zone_template => { :id => "" }
    
    response.should_not be_redirect
    response.should render_template('domains/new')
    assigns[:zone_templates].should_not be_empty
  end
  
  it "should build from a zone template if selected" do
    @zone_template = zone_templates(:east_coast_dc)
    ZoneTemplate.stubs(:find).with('1').returns(@zone_template)
    
    post 'create', :domain => { :name => 'example.org', :zone_template_id => "1" }
    
    assigns[:domain].should_not be_nil
    response.should be_redirect
    response.should redirect_to( domain_path(assigns[:domain]) )
  end
  
  it "should be redirected to the zone details after a successful save" do
    post 'create', :domain => { 
      :name => 'example.org', :primary_ns => 'ns1.example.org', 
      :contact => 'admin@example.org', :refresh => 10800, :retry => 7200,
      :expire => 604800, :minimum => 10800, :zone_template_id => "" }
    
    response.should be_redirect
    response.should redirect_to( domain_path( assigns[:domain] ) )
    flash[:info].should_not be_nil
  end
  
  it "should offer to create templates if none are found" do
    pending "Move to view specs"
  end
  
end

describe DomainsController do
  fixtures :all
  
  before(:each) do
    login_as(:admin)
  end
  
  it "should accept ownership changes" do
    domain = domains(:example_com)
    
    lambda {
      put :change_owner, :id => domain.id, :domain => { :user_id => users(:quentin).id }
      domain.reload
    }.should change( domain, :user_id )
    
    response.should render_template('domains/change_owner')
  end
end

describe DomainsController, "should handle a REST client" do
  fixtures :all
  
  before(:each) do
    authorize_as(:api_client)
  end
  
  it "creating a new zone without a template" do
    lambda {
      post 'create', :domain => { 
        :name => 'example.org', :primary_ns => 'ns1.example.org', 
        :contact => 'admin@example.org', :refresh => 10800, :retry => 7200,
        :expire => 604800, :minimum => 10800
      }, :format => "xml"
    }.should change( Domain, :count ).by( 1 )
    
    response.should have_tag( 'domain' )
  end
  
  it "creating a zone with a template" do
    post 'create', :domain => { :name => 'example.org', 
      :zone_template_id => zone_templates(:east_coast_dc).id }, 
      :format => "xml"
    
    response.should have_tag( 'domain' )
  end
  
  it "creating a zone with a named template" do
    post 'create', :domain => { :name => 'example.org', 
      :zone_template_name => zone_templates(:east_coast_dc).name }, 
      :format => "xml"
    
    response.should have_tag( 'domain' )
  end
  
  it "creating a zone with invalid input" do
    lambda {
      post 'create', :domain => {
        :name => 'example.org'
      }, :format => "xml"
    }.should_not change( Domain, :count )
    
    response.should have_tag( 'errors' )
  end
end

describe DomainsController, "and auth tokens" do
  fixtures :all
  
  before(:each) do
    tokenize_as(:token_example_com)
  end
  
  it "should display the domain in the token" do
    get :show, :id => domains(:example_com)
    
    response.should render_template('domains/show')
  end
  
  it "should restrict the domain to that of the token" do
    get :show, :id => rand(1_000_000)
    
    assigns[:domain].should eql(domains(:example_com))
  end
  
  it "should not allow a list of domains" do
    get :index
    
    response.should be_redirect
  end
  
  it "should not accept updates to the domain" do
    put :update, :id => domains(:example_com), :domain => { :name => 'hack' }
    
    response.should be_redirect
  end
end
