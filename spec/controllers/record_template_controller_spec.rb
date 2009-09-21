require File.dirname(__FILE__) + '/../spec_helper'

describe RecordTemplatesController, "when updating SOA records" do

  it "should accept a valid update" do
    login_as(Factory(:admin))

    zt = Factory(:zone_template)
    target_soa = Factory(:template_soa, :zone_template => zt)

    put "update", :id => target_soa.id, :record_template => {
      :retry => "7200", :primary_ns => 'ns1.provider.net',
      :contact => 'east-coast@example.com', :refresh => "10800", :minimum => "10800",
      :expire => "604800"
    }

    target_soa.reload
    target_soa.primary_ns.should eql('ns1.provider.net')
  end

end
