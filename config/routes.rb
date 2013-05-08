EVoucher::Application.routes.draw do
  devise_for :users

  root :to => 'management#index'

  match '/clinics' => 'home#clinics'

  resources :batches, :only => [:index]

  resources :sites do
    namespace :cards, :module => false, :controller => 'cards' do
      get '/', :action => :index
      post :batch_assign
      post :assign
      post :return
    end

    resources :clinics
    resources :mentors, :only => [:create, :destroy]
  end

  resources :providers, :only => [:create, :destroy]
  resources :patients, :only => [] do
    member do
      get 'assign_card'
      post 'do_assign_card', :path => 'assign_card', :as => 'assign_card'
    end
  end

  resources :transactions, :only => [:index]

  match '/manage_site' => 'management#index', :as => 'manage_sites'
  match '/manage_site/:site_id' => 'management#index', :as => 'manage_site'
  match '/manage_site/:site_id/:mentor_id' => 'management#index', :as => 'manage_site_mentor'

  # for instedd-platform-rails
  match 'terms_and_conditions' => redirect("http://instedd.org/terms-of-service/")
end
