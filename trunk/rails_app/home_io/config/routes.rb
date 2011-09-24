HomeIo::Application.routes.draw do
  # statistics calculated by day
  resources :day_statistics, :except => [:new, :create, :edit, :update, :delete]

  # all in one place
  resource :dashboard, :except => [:new, :create, :edit, :update, :delete]

  resources :home_archives

  # comments, and commentable resources
  resources :comments do
    resources :comments
  end

  resources :action_events do
    resources :comments
  end
  # end of commentable resources

  # overseers
  resources :overseers do
    #resources :overseer_parameters
    #resources :action_events

    get :status, :on => :collection
  end

# actions
  resources :action_types, :except => [:new, :create, :edit, :update, :delete] do
    resources :action_events
    get :execute, :on => :member
  end


#get "meas_cache/index"

# memos created by users, readable by all
  resources :memos

# measurement types
  resources :meas_types do
    resources :meas_archives do
      get :chart, :on => :collection
      resources :comments
    end

    resource :meas_cache
  end

  resources :meas_caches, :only => [:index] do
  end


  resources :cities do
    #get :chart, :on => :collection
    #resources :weathers # TODO remove this resource
    resources :weather_metar_archives, :only => [:index, :show]
    resources :weather_archives, :only => [:index, :show]
  end

  resource :user_session do
    # some problems with delete method
    get :logout
  end

  resource :account, :controller => "users"
  resources :users


# The priority is based upon order of creation:
# first created -> highest priority.

# Sample of regular route:
#   match 'products/:id' => 'catalog#view'
# Keep in mind you can assign values other than :controller and :action

# Sample of named route:
#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
# This route can be invoked with purchase_url(:id => product.id)

# Sample resource route (maps HTTP verbs to controller actions automatically):
#   resources :products

# Sample resource route with options:
#   resources :products do
#     member do
#       get 'short'
#       post 'toggle'
#     end
#
#     collection do
#       get 'sold'
#     end
#   end

# Sample resource route with sub-resources:
#   resources :products do
#     resources :comments, :sales
#     resource :seller
#   end

# Sample resource route with more complex sub-resources
#   resources :products do
#     resources :comments
#     resources :sales do
#       get 'recent', :on => :collection
#     end
#   end

# Sample resource route within a namespace:
#   namespace :admin do
#     # Directs /admin/products/* to Admin::ProductsController
#     # (app/controllers/admin/products_controller.rb)
#     resources :products
#   end

# You can have the root of your site routed with "root"
# just remember to delete public/index.html.
# root :to => "welcome#index"
#root :controller => "user_sessions", :action => "new"
  root :controller => "welcome", :action => "index"

# See how all your routes lay out with "rake routes"

# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id(.:format)))'
end
