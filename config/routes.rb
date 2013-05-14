EVoucher::Application.routes.draw do
  devise_for :users

  # Nuntium routes
  post '/nuntium/receive'

  root :to => 'management#index'

  match '/clinics' => 'home#clinics'

  resources :batches, :only => [:index]

  resources :sites, :except => [:show] do
    member do
      get :assign_cards
      post :batch_assign_cards
      post :assign_individual_card
      post :return_cards
    end

    resources :clinics
    resources :mentors, :only => [:create, :destroy]
  end

  resources :cards, :only => [] do
    member do
      post 'start_validity'
    end
  end

  resources :providers, :only => [:create, :destroy]
  resources :patients, :only => [] do
    member do
      post 'assign_card'
      post 'lost_card'
    end
  end

  resources :transactions, :only => [:index]

  namespace 'manage_site', :module => false, :controller => 'management', :as => '' do
    get '/', :action => :index, :as => 'manage_sites'
    get '/:site_id', :action => :index, :as => 'manage_site'
    get '/:site_id/:mentor_id', :action => :index, :as => 'manage_site_mentor'
    post '/:site_id/:mentor_id/add_patients', :action => :add_patients, :as => 'manage_site_add_patients'
    post '/:site_id/:mentor_id/assign', :action => :assign, :as => 'manage_site_auto_assign'
    post '/:site_id/move_patients', :action => :move, :as => 'manage_site_move_patients'
  end

  match '/welcome' => 'home#index'

  # for instedd-platform-rails
  match 'terms_and_conditions' => redirect("http://instedd.org/terms-of-service/")
end
