Rails.application.routes.draw do
  require 'sidekiq/web'
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
    mount Sidekiq::Web, at: '/sidekiq'
  end
  
  root 'posts#index'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  resources :users, only: %i[index new create show]
  resources :posts, shallow: true do
    collection do
      get :search
    end
    resources :comments
  end
  resources :likes, only: %i[create destroy]
  resources :relationships, only: %i[create destroy]
  resources :activities, only: [] do
    patch :read, on: :member
  end

  resources :chatrooms, only: %i[index create show], shallow: true do
    resources :messages
  end

  namespace :mypage do
    resource :account, only: %i[edit update]
    resources :activities, only: %i[index]
    resource :notification_setting, only: %i[edit update]
    resource :creditcard, only: %i[new create edit update]
    resources :plans, only: %i[index]
    resource :contract, only: %i[create] do
      resource :contract_cancellation, module: :contract, path: :cancellation, only: :create
    end
    resources :payments, only: %i[index]
  end
end