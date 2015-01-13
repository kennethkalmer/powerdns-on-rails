require 'spec_helper'

describe ReportsController, "index" do
  before(:each) do
    sign_in(FactoryGirl.create(:admin))

    FactoryGirl.create(:domain)
    q = FactoryGirl.create(:quentin)
    FactoryGirl.create(:domain, :name => 'example.net', :user => q)
  end

  it "should display all users to the admin" do
    get 'index'

    expect(response).to render_template('reports/index')
    expect(assigns(:users)).not_to be_empty
    expect(assigns(:users).size).to be(1)
  end

  it "should display total system domains and total domains to the admin" do
    get 'index'

    expect(response).to render_template('reports/index')
    expect(assigns(:total_domains)).to be(Domain.count)
    expect(assigns(:system_domains)).to be(1)
  end
end

describe ReportsController, "results" do
  before(:each) do
    sign_in(FactoryGirl.create(:admin))
  end

  it "should display a list of users for a search hit" do
    FactoryGirl.create(:aaron)
    FactoryGirl.create(:api_client)

    get 'results', :q => "a"

    expect(response).to render_template('reports/results')
    expect(assigns(:results)).not_to be_empty
    expect(assigns(:results).size).to be(3)
  end

  it "should redirect to reports/index if the search query is empty" do
    get 'results' , :q => ""

    expect(response).to be_redirect
    expect(response).to redirect_to( reports_path )
  end

end

describe ReportsController , "view" do
  before(:each) do
    sign_in(FactoryGirl.create(:admin))
  end

  it "should show a user reports" do
    get "view" , :id => FactoryGirl.create(:aaron).id

    expect(response).to render_template("reports/view")
    expect(assigns(:user)).not_to be_nil
    expect(assigns(:user).login).to eq('aaron')
  end

end

