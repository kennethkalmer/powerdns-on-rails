ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  map.root :controller => 'dashboard'

  # RESTful zones and records
  map.resources :domains, :has_many => :records, :member => {
    :update_note => :put,
    :change_owner => :put,
    :apply_macro => [:get,:post]
  }
  map.resources :records, :member => { :update_soa => :put }
  map.resources :soa, :controller => 'records'

  # RESTful templates
  map.resources :zone_templates, :controller => 'templates'
  map.resources :record_templates

  # RESTful macros
  map.resources :macros do |macro|
    macro.resources :macro_steps
  end

  # Audits
  map.audits '/audits/:action/:id', :controller => 'audits', :action => 'index'
  map.reports '/reports/:action/:id' , :controller => 'reports' , :action => 'index'

  # AuthTokens
  map.resource :auth_token
  map.token '/token/:token', :controller => 'sessions', :action => 'token'

  # Authentication routes
  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete }
  map.resource :session
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
