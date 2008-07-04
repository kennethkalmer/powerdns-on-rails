require File.dirname(__FILE__) + '/../spec_helper'

describe RecordsController do
  fixtures(:all)
  
  it "should create a new record when valid" do
    post :create, :record => { }
  end
end


