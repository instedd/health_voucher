EVoucher::Application.routes.draw do
  devise_for :users, :skip => :registrations

  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'    
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  # Nuntium routes
  post '/nuntium/receive'

  root :to => 'home#index'

  resources :sites, except: [:destroy] do
    member do
      get :assign_cards
      post :batch_assign_cards
      post :assign_individual_card
      post :return_cards
      
      get 'manager' => :edit_manager
      put 'manager' => :update_manager
      delete 'manager' => :destroy_manager
      post 'set_manager'

      get 'patients' => :patients
      get 'providers' => :providers
    end

    resources :clinics, except: [:new, :edit, :update] do
      member do
        get 'services'
        post 'toggle_service'
        post 'set_service_cost'
      end
    end

    resources :mentors, except: [:new, :update, :edit] do
      member do
        post 'add_patients'
        post 'auto_assign'
        post 'move_patients'
        post 'batch_validate'
      end
    end
  end

  resources :batches, :only => [:index, :show, :new, :create] do
    collection do
      get 'refresh'
    end
  end

  resources :cards, :only => [] do
    member do
      post 'start_validity'
    end
  end

  resources :providers, :only => [:create, :destroy] do
    member do
      post 'toggle'
    end
  end

  resources :patients, :only => [:destroy] do
    member do
      post 'assign_card'
      post 'unassign_card'
      post 'lost_card'
    end
  end

  resources :transactions, :only => [:index] do
    member do
      post 'update_status'
    end
  end

  resources :statements, :only => [:index, :show, :destroy] do
    collection do
      get 'generate'
      post 'do_generate'
      post 'export'
    end
    member do
      post 'toggle_status'
    end
  end

  resources :activities, :only => [:index] do
  end

  resources :users, :except => [:show] do
  end

  resources :messages, :only => [:index] do
  end

  scope 'reports', :as => 'reports', :controller => :reports do
    get '/', to: redirect('/reports/agep_ids')
    get :agep_ids
    get :voucher_usage
    get :txns_per_clinic
    get :txns_per_site
  end

  # for instedd-platform-rails
  match 'terms_and_conditions' => redirect("http://instedd.org/terms-of-service/")
end
