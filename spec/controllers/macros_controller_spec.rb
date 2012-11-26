require 'spec_helper'

describe MacrosController, "for admins" do

  before(:each) do
    sign_in( FactoryGirl.create(:admin) )

    @macro = FactoryGirl.create(:macro)

    FactoryGirl.create(:quentin)
  end

  it "should have a list of macros" do
    get :index

    assigns(:macros).should_not be_nil

    response.should render_template('macros/index')
  end

  it "should have a detailed view of a macro" do
    get :show, :id => @macro.id

    assigns(:macro).should == @macro

    response.should render_template('macros/show')
  end

  it "should have a form for creating new macros" do
    get :new

    assigns(:macro).should be_a_new_record

    response.should render_template('macros/edit')
  end

  it "should create valid macros" do
    expect {
      post :create, :macro => {
        :name => 'Test Macro',
        :active => '0'

      }
    }.to change(Macro, :count).by(1)

    flash[:notice].should_not be_nil
    response.should be_redirect
    response.should redirect_to( macro_path(assigns(:macro) ) )
  end

  it "should render the form on invalid macros" do
    post :create, :macro => {
      :name => ''
    }

    flash[:info].should be_nil
    response.should_not be_redirect
    response.should render_template('macros/edit')
  end

  it "should have an edit form for macros" do
    get :edit, :id => @macro.id

    assigns(:macro).should == @macro

    response.should render_template('macros/edit')
  end

  it "should accept valid updates to macros" do
    expect {
      put :update, :id => @macro.id, :macro => { :name => 'Foo Macro' }
      @macro.reload
    }.to change(@macro, :name)

    flash[:notice].should_not be_nil
    response.should be_redirect
    response.should redirect_to( macro_path( @macro ) )
  end

  it "should reject invalid updates" do
    expect {
      put :update, :id => @macro.id, :macro => { :name => '' }
      @macro.reload
    }.to_not change(@macro, :name)

    flash[:notice].should be_blank
    response.should_not be_redirect
    response.should render_template('macros/edit')
  end

  it "should remove a macro if asked to" do
    delete :destroy, :id => @macro.id

    assigns(:macro).should be_frozen
    flash[:notice].should_not be_nil
    response.should be_redirect
    response.should redirect_to( macros_path )
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

    assigns(:users).should be_nil
    assigns(:macro).should be_a_new_record

    response.should render_template('macros/edit')
  end

end

