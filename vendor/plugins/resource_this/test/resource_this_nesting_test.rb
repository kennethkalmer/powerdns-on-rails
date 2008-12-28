require File.join(File.dirname(__FILE__), 'test_helper')

class ResourceThisNestingTest < Test::Unit::TestCase
  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @request.accept = 'application/xml'  
    @response   = ActionController::TestResponse.new
    @first = Post.create(:title => "test", :body => "test")
    @second = Post.create(:title => "test2", :body => "test2")
    @first_comment = Comment.create(:post => @first, :body => "test")
    @second_comment = Comment.create(:post => @second, :body => "test")
    ActionController::Routing::Routes.draw do |map|  
      map.resources :posts do |post|
        post.resources :comments
      end
      map.resources :comments
    end
  end
  
  def teardown
    Post.find(:all).each { |post| post.destroy }
    Comment.find(:all).each { |comment| comment.destroy }
  end

  def test_should_get_index
    get :index, :post_id => @first.id
    assert_response :success
    assert_equal @first.comments, assigns(:comments)
    assert_equal @first, assigns(:post)
  end

  def test_should_get_index_without_post
    get :index
    assert_response :success
    assert assigns(:post).nil?
    assert_equal Comment.find(:all), assigns(:comments)
  end

  def test_should_get_new
    get :new, :post_id => @first.id
    assert_response :success
    assert assigns(:comment)
    assert assigns(:post)
  end

  def test_should_get_new_without_post
    get :new
    assert_response :success
    assert assigns(:post).nil?
    assert assigns(:comment)
  end

  def test_should_create_comment
    assert_difference('Comment.count') do
      post :create, :post_id => @first.id, :comment => { :body => "test" }
    end
    assert_response :created
    assert assigns(:comment)
    assert assigns(:post)
  end
  
  def test_should_create_comment_html
    @request.accept = 'text/html'
    assert_difference('Comment.count') do
      post :create, :post_id => @first.id, :comment => { :body => "test" }
    end
    assert_redirected_to "posts/#{assigns(:post).id}/comments/#{assigns(:comment).id}"
  end

  def test_should_create_comment_html_without_post
    @request.accept = 'text/html'
    assert_difference('Comment.count') do
      post :create, :comment => { :body => "test" }
    end
    assert_redirected_to "/comments/#{assigns(:comment).id}"
  end

  def test_should_show_comment
    get :show, :post_id => @first.id, :id => @first_comment.id
    assert_response :success
    assert assigns(:comment)
    assert assigns(:post)
  end

  def test_should_show_comment_without_post
    get :show, :id => @first_comment.id
    assert_response :success
    assert_equal Comment.find(@first_comment.id), assigns(:comment)
    assert assigns(:post).nil?
  end

  def test_should_update_comment
    put :update, :post_id => @first.id, :id => @first_comment.id, :comment => { :post => @first, :body => "test" }
    assert_response :success
    assert assigns(:comment)
    assert assigns(:post)
  end
  
  def test_should_update_comment_html
    @request.accept = 'text/html'
    put :update, :post_id => @first.id, :id => @first_comment.id, :comment => { :post => @first, :body => "test" }
    assert_redirected_to "posts/#{assigns(:post).id}/comments/#{assigns(:comment).id}"
  end

  def test_should_update_comment_html_without_post
    @request.accept = 'text/html'
    put :update, :id => @first_comment.id, :comment => { :post => @first, :body => "test2" }
    assert_redirected_to "/comments/#{assigns(:comment).id}"
  end

  def test_should_destroy_comment
    assert_difference('Comment.count', -1) do
      delete :destroy, :post_id => @first.id, :id => @first_comment.id
    end
    assert_response :success
  end
  
  def test_should_destroy_html
    @request.accept = 'text/html'
    assert_difference('Comment.count', -1) do
      delete :destroy, :post_id => @first.id, :id => @first_comment.id
    end
    assert_redirected_to "posts/#{assigns(:post).id}/comments"
  end

  def test_should_destroy_html_without_post
    @request.accept = 'text/html'
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => @first_comment.id
    end
    assert_redirected_to "/comments"
  end
end
