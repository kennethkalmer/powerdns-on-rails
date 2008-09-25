require File.dirname(__FILE__) + '/../../spec_helper'

describe "/audits/domain", "and domain audits" do 
  fixtures :domains, :records, :audits
  
  before(:each) do
    @domain = domains(:example_com)
  end
  
  it "should handle no audit entries on the domain" do
    assigns[:domain] = @domain
    render "/audits/domain"
    
    response.should have_tag("em", /No revisions found for the domain/)
  end
  
  it "should handle audit entries on the domain" do
    audit = Audit.new( 
      :auditable => @domain, 
      :created_at => Time.now, 
      :version => 1, 
      :changes => {}, 
      :action => 'create',
      :username => 'admin'
    )
    @domain.expects(:audits).at_most(2).returns( [ audit ] )
    
    assigns[:domain] = @domain
    render "/audits/domain"
    
    response.should have_tag("ul > li > a", /1 create by/)
  end
  
end

describe "/audits/domain", "and resource record audits" do
  fixtures :domains, :records, :audits
  
  before(:each) do
    @domain = domains(:example_com)
  end
  
  it "should handle no audit entries" do
    @domain.expects(:record_audits).at_most(2).returns( [] )
    assigns[:domain] = @domain
    
    render "/audits/domain"
    
    response.should have_tag("em", /No revisions found for any resource records of the domain/)
  end
  
  it "should handle audit entries" do
    assigns[:domain] = @domain
    
    render "/audits/domain"
    
    response.should have_tag("ul > li > a", /1 destroy by admin/)
  end
  
end
