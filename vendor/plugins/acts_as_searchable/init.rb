require 'acts_as_searchable'
ActiveRecord::Base.send(:include, Shooter::Acts::Searchable)
