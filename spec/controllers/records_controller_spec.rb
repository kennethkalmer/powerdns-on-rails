require File.dirname(__FILE__) + '/../spec_helper'

describe RecordsController, ", users, and non-SOA records" do
  fixtures :users, :domains, :records

  before( :each ) do
    login_as(:admin)

    @domain = domains( :example_com )
  end

  # Test adding various records
  [
   { :name => '', :ttl => '86400', :type => 'NS', :content => 'ns3.example.com' },
   { :name => '', :ttl => '86400', :type => 'A', :content => '127.0.0.1' },
   { :name => '', :ttl => '86400', :type => 'MX', :content => 'mail.example.com', :prio => '10' },
   { :name => 'foo', :ttl => '86400', :type => 'CNAME', :content => 'bar.example.com' },
   { :name => '', :ttl => '86400', :type => 'AAAA', :content => '::1' },
   { :name => '', :ttl => '86400', :type => 'TXT', :content => 'Hello world' },
   { :name => '166.188.77.208.in-addr.arpa.', :type => 'PTR', :content => 'www.example.com' },
   # TODO: Test these
   { :type => 'SPF', :pending => true },
   { :type => 'LOC', :pending => true },
   { :type => 'SPF', :pending => true }
  ].each do |record|
    it "should create a #{record[:type]} record when valid" do
      pending "Still need test for #{record[:type]}" if record.delete(:pending)

      lambda {
        post :create, :domain_id => @domain.id, :record => record
      }.should change( @domain.records, :count ).by(1)

      assigns[:domain].should_not be_nil
      assigns[:record].should_not be_nil
    end
  end

  it "shouldn't save when invalid" do
    params = {
      'name' => "",
      'ttl' => "864400",
      'type' => "NS",
      'content' => ""
    }

    post :create, :domain_id => @domain.id, :record => params

    response.should render_template( 'records/create' )
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

    response.should render_template("records/update")
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
    response.should render_template( "records/update" )
  end

  it "should destroy when requested to do so" do
    delete :destroy, :domain_id => @domain.id, :id => records(:example_com_mx).id

    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )

  end
end

describe RecordsController, ", users, and SOA records" do
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

describe RecordsController, "and tokens" do
  fixtures :auth_tokens, :domains, :records, :users

  before( :each ) do
    @domain = domains( :example_com )
    @token = AuthToken.new(
      :domain => @domain, :expires_at => 1.hour.since, :user => users(:admin)
    )
  end

  it "should not be allowed to touch the SOA record" do
    tokenize_as(:token_example_com)

    target_soa = records(:example_com_soa)

    lambda {
      put "update_soa", :id => target_soa.id, :domain_id => target_soa.domain.id,
        :soa => {
          :primary_ns => 'ns1.example.com', :contact => 'dnsadmin@example.com',
          :refresh => "10800", :retry => "10800", :minimum => "10800", :expire => "604800"
        }
        target_soa.reload
    }.should_not change( target_soa, :contact )
  end

  it "should not allow new NS records" do
    controller.stubs(:current_token).returns(@token)

    params = {
      'name' => '',
      'ttl' => '86400',
      'type' => 'NS',
      'content' => 'n3.example.com'
    }

    lambda {
      post :create, :domain_id => @domain.id, :record => params
    }.should_not change( @domain.records, :size )

    response.should_not be_success
    response.code.should == "403"
  end

  it "should not allow updating NS records" do
    controller.stubs(:current_token).returns(@token)

    record = records(:example_com_ns_ns1)

    params = {
      'name' => '',
      'ttl' => '86400',
      'type' => 'NS',
      'content' => 'ns1.somewhereelse.com'
    }

    lambda {
      put :update, :id => record.id, :domain_id => @domain.id, :record => params
      record.reload
    }.should_not change( record, :content )

    response.should_not be_success
    response.code.should == "403"
  end

  it "should create when allowed" do
    @token.allow_new_records = true
    controller.stubs(:current_token).returns(@token)

    params = {
      'name' => 'test',
      'ttl' => '86400',
      'type' => 'A',
      'content' => '127.0.0.2'
    }

    lambda {
      post :create, :domain_id => @domain.id, :record => params
    }.should change( @domain.records, :size )

    response.should be_success

    assigns[:domain].should_not be_nil
    assigns[:record].should_not be_nil

    # Ensure the token han been updated
    @token.can_change?( 'test', 'A' ).should be_true
    @token.can_remove?( 'test', 'A' ).should be_true
  end

  it "should not create if not allowed" do
    controller.stubs(:current_token).returns(@token)

    params = {
      'name' => "test",
      'ttl' => "864400",
      'type' => "A",
      'content' => "127.0.0.2"
    }

    lambda {
      post :create, :domain_id => @domain.id, :record => params
    }.should_not change( @domain.records, :size )

    response.should_not be_success
    response.code.should == "403"
  end

  it "should update when allowed" do
    record = records(:example_com_a_www)
    @token.can_change( record )
    controller.stubs(:current_token).returns( @token )

    params = {
      'name' => "www",
      'ttl' => "864400",
      'type' => "A",
      'content' => "10.0.1.10"
    }

    lambda {
      put :update, :id => record.id, :domain_id => @domain.id, :record => params
      record.reload
    }.should change( record, :content )

    response.should be_success
    response.should render_template("update")
  end

  it "should not update if not allowed" do
    record = records(:example_com_a_www)
    controller.stubs(:current_token).returns(@token)

    params = {
      'name' => "www",
      'ttl' => '',
      'type' => "A",
      'content' => "10.0.1.10"
    }

    lambda {
      put :update, :id => record.id, :domain_id => @domain.id, :record => params
      record.reload
    }.should_not change( record, :content )

    response.should_not be_success
    response.code.should == "403"
  end

  it "should destroy when allowed" do
    record = records(:example_com_mx)
    @token.can_change( record )
    @token.remove_records=( true )
    controller.stubs(:current_token).returns(@token)

    lambda {
      delete :destroy, :domain_id => @domain.id, :id => record.id
    }.should change( @domain.records, :size ).by(-1)

    response.should be_redirect
    response.should redirect_to( domain_path( @domain ) )
  end

  it "should not destroy records if not allowed" do
    controller.stubs(:current_token).returns( @token )

    lambda {
      delete :destroy, :domain_id => @domain.id, :id => records(:example_com_a)
    }.should_not change( @domain.records, :count )

    response.should_not be_success
    response.code.should == "403"
  end

  it "should not allow tampering with other domains" do
    @token.allow_new_records=( true )
    controller.stubs( :current_token ).returns( @token )

    record = {
      'name' => 'evil',
      'type' => 'A',
      'content' => '127.0.0.3'
    }

    post :create, :domain_id => domains(:example_net).id, :record => record

    response.code.should == "403"
  end
end
