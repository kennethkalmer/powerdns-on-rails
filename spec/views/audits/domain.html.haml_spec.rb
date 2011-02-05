require 'spec_helper'

describe "/audits/domain" do
  context "and domain audits" do

    before(:each) do
      @domain = Factory(:domain)
    end

    it "should handle no audit entries on the domain" do
      @domain.expects(:audits).returns( [] )
      assign(:domain, @domain)

      render

      rendered.should have_tag("em", :content => "No revisions found for the domain")
    end

    it "should handle audit entries on the domain" do
      audit = Audit.new(
        :auditable => @domain,
        :created_at => Time.now,
        :version => 1,
        :audited_changes => {},
        :action => 'create',
        :username => 'admin'
      )
      @domain.expects(:audits).at_most(2).returns( [ audit ] )

      assign(:domain, @domain)
      render

      rendered.should have_tag("ul > li > a", /1 create by/)
    end

  end

  context "and resource record audits" do

    before(:each) do
      Audit.as_user( 'admin' ) do
        @domain = Factory(:domain)
      end
    end

    it "should handle no audit entries" do
      @domain.expects(:record_audits).at_most(2).returns( [] )
      assign(:domain, @domain)

      render

      rendered.should have_tag("em", :content => "No revisions found for any resource records of the domain")
    end

    it "should handle audit entries" do
      assign(:domain, @domain)

      render

      rendered.should have_tag("ul > li > a", /1 create by admin/)
    end

  end
end
