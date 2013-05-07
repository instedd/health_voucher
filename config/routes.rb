EVoucher::Application.routes.draw do
  devise_for :users

  root :to => 'home#index'

  resources :batches do
  end

  resources :sites do
    namespace :cards, :module => false, :controller => 'cards' do
      get '/', :action => :index
      post :batch_assign
      post :assign
      post :return
    end
  end

  resources :clinics

  resources :transactions do
  end

  # for instedd-platform-rails
  match 'terms_and_conditions' => redirect("http://instedd.org/terms-of-service/")
end
