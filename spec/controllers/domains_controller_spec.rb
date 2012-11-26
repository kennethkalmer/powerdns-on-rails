require 'spec_helper'

describe DomainsController, "index" do

  it "should display all zones to the admin" do
    sign_in(FactoryGirl.create(:admin))
    FactoryGirl.create(:domain)
    get 'index'
    response.should render_template('domains/index')
    assigns(:domains).should_not be_empty
    assigns(:domains).size.should be(Domain.count)
  end

  it "should restrict zones for owners" do
    quentin = FactoryGirl.create(:quentin)
    FactoryGirl.create(:domain, :user => quentin)
    FactoryGirl.create(:domain, :name => 'example.net')

    sign_in( quentin )

    get 'index'

    response.should render_template('domains/index')
    assigns(:domains).should_not be_empty
    assigns(:domains).size.should be(1)
  end

  it "should display all zones as XML" do
    sign_in(FactoryGirl.create(:admin))

    FactoryGirl.create(:domain)

    get :index, :format => 'xml'

    assigns(:domains).should_not be_empty
    response.should have_tag('domains')
  end
end

describe DomainsController, "when creating" do

  before(:each) do
    sign_in(FactoryGirl.create(:admin))
  end

  it "should have a form for adding a new zone" do
    FactoryGirl.create(:template_soa, :zone_template => FactoryGirl.create(:zone_template))
    FactoryGirl.create(:zone_template, :name => 'No SOA')

    get 'new'

    response.should render_template('domains/new')
  end

  it "should not save a partial form" do
    FactoryGirl.create(:template_soa, :zone_template => FactoryGirl.create(:zone_template))
    FactoryGirl.create(:zone_template, :name => 'No SOA')

    expect {
      post 'create', :domain => { :name => 'example.org' }, :zone_template => { :id => "" }
    }.to_not change( Domain, :count )

    response.should_not be_redirect
    response.should render_template('domains/new')
  end

  it "should build from a zone template if selected" do
    zone_template = FactoryGirl.create(:zone_template)
    FactoryGirl.create(:template_soa, :zone_template => zone_template)

    expect {
      post 'create', :domain => { :name => 'example.org', :zone_template_id => zone_template.id }
    }.to change( Domain, :count ).by(1)

    assigns(:domain).should_not be_nil
    response.should be_redirect
    response.should redirect_to( domain_path(assigns(:domain)) )
  end

  it "should be redirected to the zone details after a successful save" do
    expect {
      post 'create', :domain => {
        :name => 'example.org', :primary_ns => 'ns1.example.org',
        :contact => 'admin@example.org', :refresh => 10800, :retry => 7200,
        :expire => 604800, :minimum => 10800, :zone_template_id => "" }
    }.to change( Domain, :count ).by(1)

    response.should be_redirect
    response.should redirect_to( domain_path( assigns(:domain) ) )
    flash[:notice].should_not be_nil
  end

  it "should ignore the zone template if a slave is created" do
    zone_template = FactoryGirl.create(:zone_template)

    expect {
      post 'create', :domain => {
        :name => 'example.org',
        :type => 'SLAVE',
        :master => '127.0.0.1',
        :zone_template_id => zone_template.id
      }
    }.to change( Domain, :count ).by(1)

    assigns(:domain).should be_slave
    assigns(:domain).soa_record.should be_nil

    response.should be_redirect
  end

end

describe DomainsController do

  before(:each) do
    sign_in(FactoryGirl.create(:admin))
  end

  it "should accept ownership changes" do
    domain = FactoryGirl.create(:domain)

    expect {
      xhr :put, :change_owner, :id => domain.id, :domain => { :user_id => FactoryGirl.create(:quentin).id }
      domain.reload
    }.to change( domain, :user_id )

    response.should render_template('domains/change_owner')
  end
end

describe DomainsController, "and macros" do

  before(:each) do
    sign_in(FactoryGirl.create(:admin))

    @macro = FactoryGirl.create(:macro)
    @domain = FactoryGirl.create(:domain)
  end

  it "should have a selection for the user" do
    get :apply_macro, :id => @domain.id

    assigns(:domain).should_not be_nil
    assigns(:macros).should_not be_empty

    response.should render_template('domains/apply_macro')
  end

  it "should apply the selected macro" do
    post :apply_macro, :id => @domain.id, :macro_id => @macro.id

    flash[:notice].should_not be_blank
    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
  end

end

describe DomainsController, "should handle a REST client" do

  before(:each) do
    sign_in(FactoryGirl.create(:api_client))

    @domain = FactoryGirl.create(:domain)
  end

  it "creating a new zone without a template" do
    expect {
      post 'create', :domain => {
        :name => 'example.org', :primary_ns => 'ns1.example.org',
        :contact => 'admin@example.org', :refresh => 10800, :retry => 7200,
        :expire => 604800, :minimum => 10800
      }, :format => "xml"
    }.to change( Domain, :count ).by( 1 )

    response.should have_tag( 'domain' )
  end

  it "creating a zone with a template" do
    zt = FactoryGirl.create(:zone_template)
    FactoryGirl.create(:template_soa, :zone_template => zt)

    post 'create', :domain => { :name => 'example.org',
      :zone_template_id => zt.id },
      :format => "xml"

    response.should have_tag( 'domain' )
  end

  it "creating a zone with a named template" do
    zt = FactoryGirl.create(:zone_template)
    FactoryGirl.create(:template_soa, :zone_template => zt)

    post 'create', :domain => { :name => 'example.org',
      :zone_template_name => zt.name },
      :format => "xml"

    response.should have_tag( 'domain' )
  end

  it "creating a zone with invalid input" do
    expect {
      post 'create', :domain => {
        :name => 'example.org'
      }, :format => "xml"
    }.to_not change( Domain, :count )

    response.should have_tag( 'errors' )
  end

  it "removing zones" do
    delete :destroy, :id => @domain.id, :format => "xml"

    expect {
      @domain.reload
    }.to raise_error(ActiveRecord::RecordNotFound)
  end


  it "viewing a list of all zones" do
    get :index, :format => 'xml'

    response.should have_selector('domains > domain')
  end

  it "viewing a zone" do
    get :show, :id => @domain.id, :format => 'xml'

    response.should have_selector('domain > records')
  end

  it "getting a list of macros to apply" do
    FactoryGirl.create(:macro)

    get :apply_macro, :id => @domain.id, :format => 'xml'

    response.should have_selector('macros > macro')
  end

  it "applying a macro to a domain" do
    macro = FactoryGirl.create(:macro)

    post :apply_macro, :id => @domain.id, :macro_id => macro.id, :format => 'xml'

    response.code.should == "202"
    response.should have_tag('domain')
  end

end

describe DomainsController, "and auth tokens" do

  before(:each) do
    @domain = FactoryGirl.create(:domain)
    @token = FactoryGirl.create(:auth_token, :user => FactoryGirl.create(:admin), :domain => @domain)

    tokenize_as(@token)
  end

  xit "should display the domain in the token" do
    get :show, :id => @domain.id

    response.should render_template('domains/show')
  end

  xit "should restrict the domain to that of the token" do
    get :show, :id => rand(1_000_000)

    assigns(:domain).should eql(@domain)
  end

  xit "should not allow a list of domains" do
    get :index

    response.should be_redirect
  end

  xit "should not accept updates to the domain" do
    put :update, :id => @domain, :domain => { :name => 'hack' }

    response.should be_redirect
  end
end
