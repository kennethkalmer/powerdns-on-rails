PowerdnsOnRails::Application.routes.draw do
  root :to => 'dashboard#index'

  resources :domains do
    member do
      put :change_owner
      get :apply_macro
      post :apply_macro
      put :update_note
    end

    resources :records do
      member do
        put :update_soa
      end
    end
  end

  resources :zone_templates, :controler => 'templates'
  resources :record_templates

  resources :macros do
    resources :macro_steps
  end

  match '/audits(/:action(/:id))' => 'audits#index', :as => :audits
  match '/reports(/:action)' => 'reports#index', :as => :reports

  resource :auth_token
  match '/token/:token' => 'sessions#token', :as => :token

  resources :users do
    member do
      put :suspend
      put :unsuspend
      delete :purge
    end
  end

  resource :session
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/:controller(/:action(/:id))'
end
