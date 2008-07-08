module Shooter
  module Acts
    module Searchable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_searchable(options = {})
          unless searchable?
            cattr_accessor :searchable_attributes, :comparison_operator, :searchable_scope_options
            include InstanceMethods
          end
          
          self.searchable_attributes ||= [] 
          self.searchable_attributes << (options.delete(:on) || [])
          self.searchable_attributes.flatten!
          self.comparison_operator = options.delete(:comparison) || :like
          self.searchable_scope_options ||= {}
          self.searchable_scope_options.update(options) {|k,v1,v2| k.to_sym == :include ? [v1 << v2].flatten.compact.uniq : v2 }
        end

        def searchable?
          self.included_modules.include?(InstanceMethods)
        end
      end

      module InstanceMethods
        def self.included(base)
          if base.respond_to?(:named_scope)
            base.named_scope :search, lambda { |query| base.searchable_scope_options.merge(:conditions => [base.searchable_attributes.map {|attribute| "#{"#{base.table_name}." unless attribute.to_s.include?(".")}#{attribute} #{base.comparison_operator.to_s.upcase} :query"}.join(" OR "), {:query => query}])}
          else
            base.extend ClassMethods
          end
        end

        module ClassMethods
          def search(query = nil, options = {})
            with_scope(:find => self.searchable_scope_options.merge(:conditions => [self.searchable_attributes.map {|attribute| "#{"#{table_name}." unless attribute.to_s.include?(".")}#{attribute} #{self.comparison_operator.to_s.upcase} :query"}.join(" OR "), {:query => query}])) do
              block_given? ? yield(options) : find(:all, options)
            end
          end
        end
      end
    end
  end
end