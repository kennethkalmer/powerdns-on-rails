require 'spec_helper'

describe ContentController do

  describe "GET 'domains'" do
    it "returns http success" do
      get 'domains'
      response.should be_success
    end
  end

end
