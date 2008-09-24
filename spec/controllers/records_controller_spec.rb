require File.dirname(__FILE__) + '/../spec_helper'

describe RecordsController, "and non-SOA records" do
  fixtures :users, :domains, :records
  
  before( :each ) do
    login_as(:admin)
    
    @domain = domains( :example_com )
  end
  
  it "should create when valid" do
    params = {
      'name' => '',
      'ttl' => '86400',
      'type' => 'NS',
      'content' => 'n3.example.com'
    }
    
    post :create, :domain_id => @domain.id, :record => params
    
    assigns[:domain].should_not be_nil
    assigns[:record].should_not be_nil
  end
  
  it "shouldn't save when invalid" do
    params = {  
      'name' => "", 
      'ttl' => "864400", 
      'type' => "NS", 
      'content' => ""
    }
    
    post :create, :domain_id => @domain.id, :record => params
    
    response.should render_template( 'new' )
  end
  
  it "should update when valid" do
    record = records(:example_com_ns_ns2)
    
    params = {  
      'name' => "", 
      'ttl' => "864400", 
      'type' => "NS", 
      'content' => "n4.example.com"
    }
    
    put :update, :id => record.id, :domain_id => @domain.id, :record => params
    
    response.should render_template("update")
  end
  
  it "shouldn't update when invalid" do
    record = records(:example_com_ns_ns2)
    
    params = {  
      'name' => "@", 
      'ttl' => '',
      'type' => "NS", 
      'content' => ""
    }
    
    lambda {
      put :update, :id => record.id, :domain_id => @domain.id, :record => params
      record.reload
    }.should_not change( record, :content )
    
    response.should_not be_redirect
    response.should render_template( "edit" )
  end
  
  it "should destroy when requested to do so" do
    delete :destroy, :domain_id => @domain.id, :id => records(:example_com_mx).id
    
    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
    
  end
end

describe RecordsController, "and SOA records" do
  fixtures :all
  
  it "should update when valid" do
    login_as(:admin)
    
    target_soa = records(:example_com_soa)
    
    put "update_soa", :id => target_soa.id, :domain_id => target_soa.domain.id,
      :soa => { 
        :primary_ns => 'ns1.example.com', :contact => 'dnsadmin@example.com',
        :refresh => "10800", :retry => "10800", :minimum => "10800", :expire => "604800"
      }
    
    target_soa.reload
    target_soa.contact.should eql('dnsadmin@example.com')
  end
end
