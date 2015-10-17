require 'spec_helper'

describe MacrosController, "for admins" do

  let(:admin) { FactoryGirl.create(:admin) }

  before(:each) do
    sign_in( admin )

    @macro = FactoryGirl.create(:macro)

    @user = FactoryGirl.create(:quentin)
  end

  it "should have a list of macros" do
    get :index

    expect(assigns(:macros)).not_to be_nil

    expect(response).to render_template('macros/index')
  end

  it "should have a detailed view of a macro" do
    get :show, :id => @macro.id

    expect(assigns(:macro)).to eq(@macro)

    expect(response).to render_template('macros/show')
  end

  it "should have a form for creating new macros" do
    get :new

    expect(assigns(:macro)).to be_a_new_record

    expect(response).to render_template('macros/edit')
  end

  it "should create valid macros" do
    expect {
      post :create, :macro => {
        :name => 'Test Macro',
        :active => '0',
        :user_id => @user.id
      }
    }.to change(Macro, :count).by(1)

    expect(flash[:notice]).not_to be_nil
    expect(response).to be_redirect
    expect(response).to redirect_to( macro_path(assigns(:macro) ) )
  end

  it "should render the form on invalid macros" do
    post :create, :macro => {
      :name => ''
    }

    expect(flash[:info]).to be_nil
    expect(response).not_to be_redirect
    expect(response).to render_template('macros/edit')
  end

  it "should have an edit form for macros" do
    get :edit, :id => @macro.id

    expect(assigns(:macro)).to eq(@macro)

    expect(response).to render_template('macros/edit')
  end

  it "should accept valid updates to macros" do
    expect {
      put :update, :id => @macro.id, :macro => { :name => 'Foo Macro', :user_id => @user.id }
      @macro.reload
    }.to change(@macro, :name)

    expect(flash[:notice]).not_to be_nil
    expect(response).to be_redirect
    expect(response).to redirect_to( macro_path( @macro ) )
  end

  it "should reject invalid updates" do
    expect {
      put :update, :id => @macro.id, :macro => { :name => '' }
      @macro.reload
    }.to_not change(@macro, :name)

    expect(flash[:notice]).to be_blank
    expect(response).not_to be_redirect
    expect(response).to render_template('macros/edit')
  end

  it "should remove a macro if asked to" do
    delete :destroy, :id => @macro.id

    expect(assigns(:macro)).to be_frozen
    expect(flash[:notice]).not_to be_nil
    expect(response).to be_redirect
    expect(response).to redirect_to( macros_path )
  end

end

describe MacrosController, "for owners" do

  before(:each) do
    quentin = FactoryGirl.create(:quentin)
    sign_in(quentin)

    @macro = FactoryGirl.create(:macro, :user => quentin)
  end

  it "should have a form to create a new macro" do
    get :new

    expect(assigns(:users)).to be_nil
    expect(assigns(:macro)).to be_a_new_record

    expect(response).to render_template('macros/edit')
  end

end

