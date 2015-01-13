require 'spec_helper'

describe MacroStepsController do

  before(:each) do
    sign_in(FactoryGirl.create(:admin))

    @macro = FactoryGirl.create(:macro)
    @step = FactoryGirl.create(:macro_step_create,
                    :macro => @macro,
                    :name => 'localhost',
                    :content => '127.0.0.1')
  end

  it "should create a valid step" do
    expect {
      post :create, :macro_id => @macro.id,
        :macro_step => {
          :action => 'create',
          :record_type => 'A',
          :name => 'www',
          :content => '127.0.0.1'
        }, :format => 'js'
    }.to change(@macro.macro_steps(true), :count)

    expect(response).to render_template('macro_steps/create')
  end

  it "should position a valid step correctly" do
    post :create, :macro_id => @macro.id,
    :macro_step => {
      :action => 'create',
      :record_type => 'A',
      :name => 'www',
      :content => '127.0.0.1',
      :position => '1'
    }, :format => 'js'

    expect(assigns(:macro_step).position).to eq(1)
  end

  it "should not create an invalid step" do
    expect {
      post :create, :macro_id => @macro.id,
        :macro_step => {
          :position => '1',
          :record_type => 'A'
        }, :format => 'js'
    }.to_not change(@macro.macro_steps(true), :count)

    expect(response).to render_template('macro_steps/create')
  end

  it "should accept valid updates to steps" do
    put :update, :macro_id => @macro.id, :id => @step.id,
      :macro_step => {
        :name => 'local'
      }, :format => 'js'

    expect(response).to render_template('macro_steps/update')

    expect(@step.reload.name).to eq('local')
  end

  it "should not accept valid updates" do
    put :update, :macro_id => @macro.id, :id => @step.id,
      :macro_step => {
        :name => ''
      }, :format => 'js'

    expect(response).to render_template('macro_steps/update')
  end

  it "should re-position existing steps" do
    FactoryGirl.create(:macro_step_create, :macro => @macro)

    put :update, :macro_id => @macro.id, :id => @step.id,
    :macro_step => { :position => '2' }

    expect(@step.reload.position).to eq(2)
  end

  it "should remove selected steps when asked" do
    delete :destroy, :macro_id => @macro, :id => @step.id, :format => 'js'

    expect(flash[:info]).not_to be_blank
    expect(response).to be_redirect
    expect(response).to redirect_to(macro_path(@macro))

    expect { @step.reload }.to raise_error( ActiveRecord::RecordNotFound )
  end

end
