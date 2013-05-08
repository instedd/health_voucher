EVoucher::Application.routes.draw do
  devise_for :users

  root :to => 'home#index'

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
  end

  resources :providers, :only => [:create, :destroy]

  resources :transactions, :only => [:index]

  # for instedd-platform-rails
  match 'terms_and_conditions' => redirect("http://instedd.org/terms-of-service/")
end
