require File.dirname(__FILE__) + '/../spec_helper'

describe RecordsController do
  fixtures :users, :domains
  
  before( :each ) do
    session[:user_id] = users( :admin ).id
    @domain = domains( :example_com )
    Domain.expects( :find ).with( @domain.id.to_s, :user => users( :admin ) ).returns( @domain )
  end
  
  it "should create a new record when valid" do
    record = Record.new
    
    params = {
      'name' => '',
      'ttl' => '86400',
      'type' => 'NS',
      'content' => 'n3.example.com'
    }
    
    @domain.ns_records.expects( :new ).with( params ).returns( record )
    record.expects( :save ).returns( true )
    
    post :create, :domain_id => @domain.id, :record => params
    
    assigns[:domain].should_not be_nil
    assigns[:record].should_not be_nil
  end
  
  it "shouldn't save an invalid record" do
    record = Record.new
    
    params = {  
      'name' => "", 
      'ttl' => "864400", 
      'type' => "NS", 
      'content' => "n3.example.com"
    }
    
    @domain.ns_records.expects( :new ).with( params ).returns( record )
    record.expects( :save ).returns( false )
    
    post :create, :domain_id => @domain.id, :record => params
    
    response.should render_template( 'new' )
  end
  
  it "should update a valid record" do
    record = Record.new
    
    params = {  
      'name' => "", 
      'ttl' => "864400", 
      'type' => "NS", 
      'content' => "n4.example.com"
    }
    
    record.expects( :save ).returns( true )
    @domain.records.expects( :find ).with( '1' ).returns( record )
    
    put :update, :id => '1', :domain_id => @domain.id, :record => params
  end
  
  it "shouldn't update an invalid record" do
    record = Record.new
    
    params = {  
      'name' => "@", 
      'ttl' => '',
      'type' => "NS", 
      'content' => "n4.example.com"
    }
    
    record.expects( :save ).returns( false )
    @domain.records.expects( :find ).with( '1' ).returns( record )
    
    put :update, :id => '1', :domain_id => @domain.id, :record => params
    
    response.should_not be_redirect
    response.should render_template( "edit" )
  end
  
  it "should destroy a record when requested to do so" do
    record = Record.new
    @domain.records.expects( :find ).with( '1' ).returns( record )
    
    delete :destroy, :domain_id => @domain.id, :id => '1'
    
    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
    
  end
end


