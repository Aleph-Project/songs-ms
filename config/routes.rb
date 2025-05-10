Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :songs do
        get 'audio', on: :member
      end
      resources :artists, only: [:index, :show]
      resources :albums, only: [:index, :show]
      resources :audios, only: [:show]
      
      # Rutas para la API de Spotify
      post 'spotify/import_albums', to: 'spotify#import_albums'
      post 'spotify/import_artist', to: 'spotify#import_artist'
      post 'spotify/import_album', to: 'spotify#import_album'  # Nueva ruta para importar un álbum específico
      get 'spotify/search_albums', to: 'spotify#search_albums'  # Nueva ruta para buscar álbumes
      get 'spotify/callback', to: 'spotify#callback'
    end
  end
  
  # Define root route to API docs or status page
  root "rails/health#show"
end
