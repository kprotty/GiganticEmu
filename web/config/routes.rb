Rails.application.routes.draw do
    get '/', to: 'home#index'
    get '/leaderboard', to: 'leaderboard#index'
    resource :match_history, only: [:index, :show]

    devise_for :users, controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions'
    }

    # Gigantic client APIs
    get '/cdn.html', to: 'clientapi/cdn#index'
    get '/auth/0.0/arc/auth', to: 'client_api/auth#index'
    post '/auth/0.0/arc/auth', to: 'client_api/auth#create'

    root to: "home#index"
end
