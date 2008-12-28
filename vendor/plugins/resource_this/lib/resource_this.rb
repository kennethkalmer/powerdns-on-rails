module ResourceThis # :nodoc:
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def resource_this(options = {})
      options.assert_valid_keys(:class_name, :will_paginate, :finder_options, :nested, :path_prefix)

      singular_name         = controller_name.singularize
      singular_name         = options[:class_name].downcase.singularize unless options[:class_name].nil?
      class_name            = options[:class_name] || singular_name.camelize
      plural_name           = singular_name.pluralize
      will_paginate_index   = options[:will_paginate] || false
      resource_url          = "#{singular_name}_url(@#{singular_name})"
      collection_url        = "#{plural_name}_url"
      resource_url          = options[:path_prefix] + resource_url unless options[:path_prefix].nil?
      collection_url        = options[:path_prefix] + collection_url unless options[:path_prefix].nil?
      
      class_inheritable_accessor :resource_this_finder_options
      self.resource_this_finder_options = options[:finder_options] || {}
      
      unless options[:nested].nil?
        nested                = options[:nested].to_s.singularize
        nested_class          = nested.camelize
        nested_resource_url   = "#{nested}_#{singular_name}_url(" + [nested, singular_name].map { |route| "@#{route}"}.join(', ') + ')'
        nested_collection_url = "#{nested}_#{plural_name}_url(@#{nested})"
        nested_resource_url   = options[:path_prefix] + nested_resource_url unless options[:path_prefix].nil?
        nested_collection_url = options[:path_prefix] + nested_collection_url unless options[:path_prefix].nil?
        module_eval <<-"end_eval", __FILE__, __LINE__
          before_filter :load_#{nested}
        end_eval
      end

      #standard before_filters
      module_eval <<-"end_eval", __FILE__, __LINE__
        before_filter :load_#{singular_name}, :only => [ :show, :edit, :update, :destroy ]
        before_filter :load_#{plural_name}, :only => [ :index ]
        before_filter :new_#{singular_name}, :only => [ :new ]
        before_filter :create_#{singular_name}, :only => [ :create ]
        before_filter :update_#{singular_name}, :only => [ :update ]
        before_filter :destroy_#{singular_name}, :only => [ :destroy ]
      
      protected
      
        def finder_options
          resource_this_finder_options.class == Proc ? resource_this_finder_options.call : {}
        end
      
      end_eval
      
      if options[:nested].nil?
        module_eval <<-"end_eval", __FILE__, __LINE__
          def finder_base
            #{class_name}
          end
          
          def collection
            #{class_name}.find(:all, finder_options)
          end
          
          def collection_url
            #{collection_url}
          end

          def resource_url
            #{resource_url}
          end
        end_eval
      else
        module_eval <<-"end_eval", __FILE__, __LINE__
          def load_#{nested}
            @#{nested} = #{nested_class}.find(params[:#{nested}_id]) rescue nil
          end
          
          def finder_base
            @#{nested}.nil? ? #{class_name} : @#{nested}.#{plural_name}
          end
          
          def collection
            @#{nested}.nil? ? #{class_name}.find(:all, finder_options) : @#{nested}.#{plural_name}.find(:all, finder_options)
          end
          
          def collection_url
            @#{nested}.nil? ? #{collection_url} : #{nested_collection_url}
          end

          def resource_url
            @#{nested}.nil? ? #{resource_url} : #{nested_resource_url}
          end
        end_eval
      end
      
      module_eval <<-"end_eval", __FILE__, __LINE__
        def load_#{singular_name}
          @#{singular_name} = finder_base.find(params[:id])
        end
        
        def new_#{singular_name}
          @#{singular_name} = finder_base.new
        end
        
        def create_#{singular_name}
          returning true do
            @#{singular_name} = finder_base.new(params[:#{singular_name}])
            @created = @#{singular_name}.save
          end
        end
        
        def update_#{singular_name}
          returning true do
            @updated = @#{singular_name}.update_attributes(params[:#{singular_name}])
          end
        end
        
        def destroy_#{singular_name}
          @#{singular_name} = @#{singular_name}.destroy
        end
      end_eval
            
      if will_paginate_index
        module_eval <<-"end_eval", __FILE__, __LINE__
          def load_#{plural_name}
            @#{plural_name} = finder_base.paginate(finder_options.merge(:page => params[:page]))
          end
        end_eval
      else
        module_eval <<-"end_eval", __FILE__, __LINE__
          def load_#{plural_name}
            @#{plural_name} = collection
          end
        end_eval
      end

      module_eval <<-"end_eval", __FILE__, __LINE__
      public
        def index
          respond_to do |format|
            format.html
            format.xml  { render :xml => @#{plural_name} }
            format.js
          end
        end

        def show          
          respond_to do |format|
            format.html
            format.xml  { render :xml => @#{singular_name} }
            format.js
          end
        end

        def new          
          respond_to do |format|
            format.html { render :action => :edit }
            format.xml  { render :xml => @#{singular_name} }
            format.js
          end
        end

        def create
          respond_to do |format|
            if @created
              flash[:notice] = '#{class_name} was successfully created.'
              format.html { redirect_to(resource_url) }
              format.xml  { render :xml => @#{singular_name}, :status => :created, :location => resource_url }
              format.js
            else
              format.html { render :action => :edit }
              format.xml  { render :xml => @#{singular_name}.errors, :status => :unprocessable_entity }
              format.js
            end
          end
        end 

        def edit
          respond_to do |format|
            format.html
            format.js
          end
        end

        def update
          respond_to do |format|
            if @updated
              flash[:notice] = '#{class_name} was successfully updated.'
              format.html { redirect_to(resource_url) }
              format.xml  { head :ok }
              format.js
            else
              format.html { render :action => :edit }
              format.xml  { render :xml => @#{singular_name}.errors, :status => :unprocessable_entity }
              format.js
            end
          end
        end

        def destroy          
          respond_to do |format|
            format.html { redirect_to(collection_url) }
            format.xml  { head :ok }
            format.js
          end
        end
      end_eval
    end
  end
end
