Rails.application.routes.draw do
  root to: 'main#index'

  namespace :user do
    namespace :session do
      get 'new'
      get 'destroy'
    end
  end

  get 'main/index'
  get 'main/waiting', as: 'waiting'
  get 'sync_user', to: 'main#sync_user', as: 'sync_user'

  post 'lucky_card', to: 'main#lucky_card', as: 'lucky_card'

  get 'login', to: "user/session#new", as: 'new_session'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
