require File.join(File.dirname(__FILE__), 'test_helper')

class ResourceThisTest < Test::Unit::TestCase
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @request.accept = 'application/xml'  
    @response   = ActionController::TestResponse.new
    @first = Post.create(:title => "test", :body => "test")
    ActionController::Routing::Routes.draw do |map| 
      map.resources :posts
    end
  end
  
  def teardown
    Post.find(:all).each { |post| post.destroy }
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:posts)
  end

  def test_should_get_new
    get :new
    assert_response :success
    assert assigns(:post)
  end

  def test_should_create_post
    assert_difference('Post.count') do
      post :create, :post => { :title => "test", :body => "test" }
    end
    assert_response :created
    assert assigns(:post)
  end
  
  def test_should_handle_invalid_post_on_create
    assert_no_difference('Post.count') do
      post :create, :post => { :title => "1" }
    end
    assert_response :unprocessable_entity
    assert assigns(:post).errors
    assert !assigns(:created)
  end
  
  
  def test_should_create_post_html
    @request.accept = 'text/html'
    assert_difference('Post.count') do
      post :create, :post => { :title => "test", :body => "test" }
    end
    assert_redirected_to "/posts/#{assigns(:post).id}"
  end

  def test_should_show_post
    get :show, :id => @first.id
    assert_response :success
    assert assigns(:post)
  end

  def test_should_update_post
    put :update, :id => @first.id, :post => { :title => "test", :body => "test" }
    assert_response :success
    assert assigns(:post)
  end
  
  def test_should_handle_invalid_post_on_update
    post :update, :id => @first.id, :post => { :title => "1" }
    assert_response :unprocessable_entity
    assert assigns(:post).errors
    assert !assigns(:updated)
  end
  
  def test_should_update_post_html
    @request.accept = 'text/html'
    put :update, :id => @first.id, :post => { :title => "test", :body => "test" }
    assert_redirected_to "/posts/#{assigns(:post).id}"
  end

  def test_should_destroy_post
    assert_difference('Post.count', -1) do
      delete :destroy, :id => @first.id
    end
    assert_response :success
  end
  
  def test_should_destroy_post_html
    @request.accept = 'text/html'
    assert_difference('Post.count', -1) do
      delete :destroy, :id => @first.id
    end
    assert_redirected_to "/posts"
  end
end
