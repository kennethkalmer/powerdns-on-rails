require File.join(File.dirname(__FILE__), 'test_helper')

class ResourceThisUrlPrefixTest < Test::Unit::TestCase
  def setup
    @controller = Admin::PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @first = Post.create(:title => "test", :body => "test")
    ActionController::Routing::Routes.draw do |map| 
      map.resources :posts
      map.with_options :path_prefix => 'admin', :name_prefix => 'admin_' do |map|
        map.resources   :posts,     :controller => 'admin/posts'
      end
    end
  end
  
  def teardown
    Post.find(:all).each { |post| post.destroy }
  end
  
  def test_should_create_post
    assert_difference('Post.count') do
      post :create, :post => { :title => "test", :body => "test" }
    end
    assert_redirected_to "/admin/posts/#{assigns(:post).id}"
  end
  
  def test_should_update_post
    put :update, :id => @first.id, :post => { :title => "test", :body => "test" }
    assert_redirected_to "/admin/posts/#{assigns(:post).id}"
  end
  
  def test_should_destroy_post
    assert_difference('Post.count', -1) do
      delete :destroy, :id => @first.id
    end
    assert_redirected_to "/admin/posts"
  end
end
