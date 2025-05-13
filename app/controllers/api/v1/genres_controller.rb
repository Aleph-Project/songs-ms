module Api
  module V1
    class GenresController < ApplicationController
      def index
        genres = MusicGenre.all.order_by(name: :asc)
        
        render json: genres.map { |genre|
          {
            id: genre.id.to_s,
            name: genre.name,
            slug: genre.slug,
            count: genre.music_artists.count
          }
        }
      end

      def show
        genre = MusicGenre.where(id: params[:id]).first || MusicGenre.where(slug: params[:id]).first

        if genre
          artists = genre.music_artists

          render json: {
            id: genre.id.to_s,
            name: genre.name,
            slug: genre.slug,
            count: artists.count,
            artists: artists.map { |artist|
              {
                id: artist.spotify_id,
                name: artist.name,
                image_url: artist.image_url
              }
            }
          }
        else
          render json: { error: "Género no encontrado" }, status: :not_found
        end
      end
    end
  end
end