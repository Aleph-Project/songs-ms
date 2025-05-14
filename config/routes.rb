Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Nueva estructura de rutas con prefijo /api/music
  scope "/api" do
    scope "/music" do
      resources :songs, controller: 'api/v1/songs' do
        get "audio", on: :member
      end
      resources :artists, only: [ :index, :show ], controller: 'api/v1/artists' do
        get "details", on: :member
      end
      resources :albums, only: [ :index, :show ], controller: 'api/v1/albums'
      resources :categories, only: [ :index, :show ], controller: 'api/v1/categories'
      resources :audios, only: [ :show ], controller: 'api/v1/audios'
      
      # Rutas para la API de Spotify con prefijo /api/music
      scope "/spotify" do
        post "import_albums", to: "api/v1/spotify#import_albums"
        post "import_artist", to: "api/v1/spotify#import_artist"
        post "import_album", to: "api/v1/spotify#import_album"
        get "search_albums", to: "api/v1/spotify#search_albums"
        get "callback", to: "api/v1/spotify#callback"
      end
    end
  end

  # API routes con prefijo /api/v1 (mantener para compatibilidad)
  namespace :api do
    namespace :v1 do
      resources :songs do
        get "audio", on: :member
      end
      resources :artists, only: [ :index, :show ]
      resources :albums, only: [ :index, :show ]
      resources :categories, only: [ :index, :show ]
      resources :audios, only: [ :show ]

      # Rutas para la API de Spotify
      post "spotify/import_albums", to: "spotify#import_albums"
      post "spotify/import_artist", to: "spotify#import_artist"
      post "spotify/import_album", to: "spotify#import_album"  # Nueva ruta para importar un álbum específico
      get "spotify/search_albums", to: "spotify#search_albums"  # Nueva ruta para buscar álbumes
      get "spotify/callback", to: "spotify#callback"
    end
  end

  # Define root route to API docs or status page
  root "rails/health#show"
  
  # Rutas alternativas compatibles con /_data/v1 (mantener para compatibilidad)
  scope "/_data" do
    namespace :v1 do
      resources :songs, controller: 'api/v1/songs'
      resources :artists, only: [ :index, :show ], controller: 'api/v1/artists'
      resources :albums, only: [ :index, :show ], controller: 'api/v1/albums'
      resources :categories, only: [ :index, :show ], controller: 'api/v1/categories'
      resources :audios, only: [ :show ], controller: 'api/v1/audios'
      
      # Rutas para la API de Spotify con prefijo /_data
      post "spotify/import_albums", to: "api/v1/spotify#import_albums"
      post "spotify/import_artist", to: "api/v1/spotify#import_artist"
      post "spotify/import_album", to: "api/v1/spotify#import_album"
      get "spotify/search_albums", to: "api/v1/spotify#search_albums"
      get "spotify/callback", to: "api/v1/spotify#callback"
    end
  end
end
