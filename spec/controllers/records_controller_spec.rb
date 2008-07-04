require File.dirname(__FILE__) + '/../spec_helper'

describe RecordsController do
  fixtures :users, :zones
  
  before( :each ) do
    session[:user_id] = users( :admin ).id
    @zone = zones( :example_com )
  end
  
  it "should create a new record when valid" do
    Zone.stubs( :find ).with( @zone.id.to_s, :user => users( :admin ) ).returns( @zone )
    
    record = Record.new
    
    params = {  
      'host' => "@", 
      'ttl' => "864400", 
      'type' => "NS", 
      'data' => "n3.example.com"
    }
    @zone.records.expects( :new ).with( params ).returns( record )
    
    record.expects( :zone_id= ).with( @zone.id )
    record.expects( :save ).returns( true )
    
    post :create, :zone_id => @zone.id, :record => params
    
    assigns[:zone].should_not be_nil
    assigns[:record].should_not be_nil
    response.should be_redirect
    response.should redirect_to( zone_path( assigns[:zone] ) )
  end
  
  it "shouldn't save an invalid record" do
    Zone.stubs( :find ).with( @zone.id.to_s, :user => users( :admin ) ).returns( @zone )
    
    record = Record.new
    
    params = {  
      'host' => "@", 
      'ttl' => "864400", 
      'type' => "NS", 
      'data' => "n3.example.com"
    }
    
    @zone.records.expects( :new ).with( params ).returns( record )
    record.expects( :zone_id= ).with( @zone.id )
    record.expects( :save ).returns( false )
    
    post :create, :zone_id => @zone.id, :record => params
  end
  
  it "should update a valid record" do
    pending
  end
  
  it "shouldn't update an invalid record" do
    pending
  end
  
  it "should destroy a record when requested to do so" do
    pending
  end
end


