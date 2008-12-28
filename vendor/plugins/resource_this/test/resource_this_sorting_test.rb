require File.join(File.dirname(__FILE__), 'test_helper')

class ResourceThisSortingTest < Test::Unit::TestCase
  def setup
    @controller = WidgetsController.new
    @request    = ActionController::TestRequest.new
    @request.accept = 'application/xml'  
    @response   = ActionController::TestResponse.new
    @a = Widget.create(:title => "aaa", :body => "zzz")
    @z = Widget.create(:title => "zzz", :body => "aaa")
    100.times do
      Widget.create(:title => "foo", :body => "bar")
    end
    ActionController::Routing::Routes.draw do |map| 
      map.resources :widgets
    end
  end
  
  def teardown
    Widget.find(:all).each { |w| w.destroy }
  end
  
  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:widgets)
    assert_equal @a, assigns(:widgets).first
  end
  
  def test_should_get_index_sorted_with_inline_proc
    @controller.resource_this_finder_options = Proc.new { { :order => 'body' } }
    get :index
    assert_response :success
    assert assigns(:widgets)
    assert_equal @z, assigns(:widgets).first
  end
  
  def test_should_get_index_sorted_with_proc
    @controller.resource_this_finder_options = Proc.new { finder_options }
    get :index
    assert_response :success
    assert assigns(:widgets)
    assert_equal 2, assigns(:widgets).size
    assert_equal @z, assigns(:widgets).first
  end
  
  def finder_options
    {:order => 'body', :limit => 2}
  end
  
end
