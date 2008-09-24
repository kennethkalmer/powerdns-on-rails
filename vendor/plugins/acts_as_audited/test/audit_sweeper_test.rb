require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class AuditsController < ActionController::Base
  audit Company, Branch, :parent => [ Branch => :company ]
  attr_accessor :current_user
  
  def audit
    @company = Company.create
    render :nothing => true
  end
  
  def parent
    @branch = Branch.create
    render :nothing => true
  end
  
end
AuditsController.view_paths = [File.expand_path(File.dirname(__FILE__) + "/../fixtures")]
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

class AuditSweeperTest < Test::Unit::TestCase

  def setup
    @controller = AuditsController.new
    @controller.logger = Logger.new(nil)
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "www.example.com"
  end
  
  def test_calls_acts_as_audited_on_non_audited_models
    assert_kind_of CollectiveIdea::Acts::Audited::SingletonMethods, Company
    assert_kind_of CollectiveIdea::Acts::Audited::SingletonMethods, Branch
  end
  
  def test_audits
    user = @controller.current_user = create_user
    assert_difference Audit, :count do
      post :audit
    end
    assert_equal user, assigns(:company).audits.last.user
  end
  
  def test_audits_parent
    user = @controller.current_user = create_user
    assert_difference Audit, :count do
      post :parent
    end
    assert_equal user, assigns(:branch).audits.last.user
  end
end
