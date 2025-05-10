module Api
  module V1
    class ArtistsController < ApplicationController
      def index
        artists = MusicArtist.all
        render json: artists.map { |artist| 
          {
            id: artist.spotify_id,
            name: artist.name,
            image_url: artist.image_url,
            genres: artist.genres,
            popularity: artist.popularity
          }
        }
      end
      
      def show
        artist = MusicArtist.where(spotify_id: params[:id]).first
        
        if artist
          render json: {
            id: artist.spotify_id,
            name: artist.name,
            image_url: artist.image_url,
            genres: artist.genres,
            popularity: artist.popularity
          }
        else
          render json: { error: "Artista no encontrado" }, status: :not_found
        end
      end
    end
  end
end