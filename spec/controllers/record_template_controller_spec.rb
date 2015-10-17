require 'spec_helper'

describe RecordTemplatesController, "when updating SOA records" do
  before(:each) do
    sign_in(FactoryGirl.create(:admin))
    @zt = FactoryGirl.create(:zone_template)
  end

  it "should create valid templates" do
    expect {
      xhr :post, :create, :record_template => {
        :retry => "7200", :primary_ns => 'ns1.provider.net',
        :contact => 'east-coast@example.com', :refresh => "10800", :minimum => "10800",
        :expire => "604800", :record_type => "SOA"
      }, :zone_template => { :id => @zt.id }

    }.to change( RecordTemplate, :count ).by(1)
  end

  it "should accept a valid update" do
    target_soa = FactoryGirl.create(:template_soa, :zone_template => @zt)

    xhr :put, :update, :id => target_soa.id, :record_template => {
      :retry => "7200", :primary_ns => 'ns1.provider.net',
      :contact => 'east-coast@example.com', :refresh => "10800", :minimum => "10800",
      :expire => "604800"
    }

    target_soa.reload
    expect(target_soa.primary_ns).to eql('ns1.provider.net')
  end

end
