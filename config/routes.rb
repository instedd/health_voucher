EVoucher::Application.routes.draw do
  devise_for :users, :skip => :registrations

  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'    
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  # Nuntium routes
  post '/nuntium/receive'

  root :to => 'home#index'

  resources :sites do
    member do
      get :assign_cards
      post :batch_assign_cards
      post :assign_individual_card
      post :return_cards
      
      get :edit_manager
      post :update_manager
    end

    resources :clinics do
      member do
        post 'toggle_service'
        post 'set_service_cost'
      end
    end

    resources :mentors do
      collection do
        post 'move_patients'
      end

      member do
        post 'add_patients'
        post 'auto_assign'
      end
    end
  end

  resources :batches, :only => [:index]

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

  resources :patients, :only => [] do
    member do
      post 'assign_card'
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
    end
    member do
      post 'toggle_status'
    end
  end

  # for instedd-platform-rails
  match 'terms_and_conditions' => redirect("http://instedd.org/terms-of-service/")
end
