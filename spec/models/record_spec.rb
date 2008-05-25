require File.dirname(__FILE__) + '/../spec_helper'

describe Record, "in general" do
  before(:each) do
    @record = Record.new
  end

  it "should be invalid by default" do
    @record.should_not be_valid
  end
  
  it "should require a zone" do
    @record.should have(1).error_on(:zone_id)
  end
  
  it "should require a ttl" do
    @record.should have(1).error_on(:ttl)
  end
  
  it "should only allow positive numeric ttl's" do
    @record.ttl = -100
    @record.should have(1).error_on(:ttl)
    
    @record.ttl = '2d'
    @record.should have(1).error_on(:ttl)
    
    @record.ttl = 86400
    @record.should have(:no).errors_on(:ttl)
  end
  
  it "should have @ as the host be default" do
    @record.host.should eql('@')
  end
  
end

describe Record, "during updates" do
  fixtures :all
  
  before(:each) do
    @soa = records( :example_com_soa )
  end
  
  it "should update the serial on the SOA" do
    serial = @soa.serial
    
    record = records( :example_com_a )
    record.data = '10.0.0.1'
    record.save.should be_true
    
    @soa.reload
    @soa.serial.should_not eql( serial )
  end
  
  it "should be able to restrict the serial number to one change (multiple updates)" do
    serial = @soa.serial
    
    # Implement some cheap DNS load balancing
    Record.batch do
      
      record = A.new(
        :zone => zones(:example_com),
        :host => 'app',
        :data => '10.0.0.5',
        :ttl => 86400
      )
      record.save.should be_true
      
      record = A.new(
        :zone => zones(:example_com),
        :host => 'app',
        :data => '10.0.0.6',
        :ttl => 86400
      )
      record.save.should be_true
      
      record = A.new(
        :zone => zones(:example_com),
        :host => 'app',
        :data => '10.0.0.7',
        :ttl => 86400
      )
      record.save.should be_true
    end
    
    # Our serial should have move just one position, not three
    @soa.reload
    @soa.serial.should_not be( serial )
    @soa.serial.to_s.should eql( Time.now.strftime( "%Y%m%d" ) + '01' )
  end
  
end

describe Record, "when created" do
  fixtures :all
  
  before(:each) do
    @soa = records( :example_com_soa )
  end
  
  it "should update the serial on the SOA" do
    serial = @soa.serial
    
    record = A.new( 
      :zone => zones(:example_com),
      :host => 'admin',
      :data => '10.0.0.5',
      :ttl => 86400
    )
    record.save.should be_true
    
    @soa.reload
    @soa.serial.should_not eql(serial)
  end
  
  it "should inherit the TTL from the parent zone if not provided" do
    ttl = zones( :example_com ).ttl
    ttl.should be( 86400 )
    
    record = A.new(
      :zone => zones( :example_com ),
      :host => 'ftp',
      :data => '10.0.0.6'
    )
    record.save.should be_true
    
    record.ttl.should be( 86400 )
  end
  
  it "should prefer own TTL over that of parent zone" do
    record = A.new(
      :zone => zones( :example_com ),
      :host => 'ftp',
      :data => '10.0.0.6',
      :ttl => 43200
    )
    record.save.should be_true
    
    record.ttl.should be( 43200 )
  end
end