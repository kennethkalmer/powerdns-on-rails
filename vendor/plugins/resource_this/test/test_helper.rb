$LOAD_PATH.unshift 'lib/'

require 'rubygems'
require 'multi_rails_init'
require 'action_controller/test_process'
require 'test/unit'
require 'resource_this'

begin
  require 'redgreen'
rescue LoadError
  nil
end

RAILS_ROOT = '.'    unless defined? RAILS_ROOT
RAILS_ENV  = 'test' unless defined? RAILS_ENV

ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']
ActionController::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']

ActionController::Base.send :include, ResourceThis

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :posts do |t|
    t.column :title,        :string
    t.column :body,         :text
    t.column :created_at,   :datetime
    t.column :updated_at,   :datetime
  end
  create_table :comments do |t|
    t.column :body,         :text
    t.column :post_id,      :integer
    t.column :created_at,   :datetime
    t.column :updated_at,   :datetime
  end
  create_table :widgets do |t|
    t.column :title,        :string
    t.column :body,         :text
    t.column :created_at,   :datetime
    t.column :updated_at,   :datetime
  end
end

class Post < ActiveRecord::Base
  has_many :comments
  validates_length_of :title, :within => 2..100
  def validate
  end
end

class Comment < ActiveRecord::Base
  belongs_to :post
  def validate
  end
  validates_associated :post
end

class Widget < ActiveRecord::Base
  def validate
  end
end

class PostsController < ActionController::Base
  resource_this
end

class WidgetsController < ActionController::Base
  resource_this
end

module Admin; end

class Admin::PostsController < ActionController::Base
  resource_this :path_prefix => "admin_"
end

class CommentsController < ActionController::Base
  resource_this :nested => [:posts]
end