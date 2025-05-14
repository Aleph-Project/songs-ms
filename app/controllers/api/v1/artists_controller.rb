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
      
      # GET /artists/:id/details
      # Obtiene toda la información relacionada con un artista: sus datos, álbumes y canciones
      def details
        begin
          artist = MusicArtist.where(spotify_id: params[:id]).first

          if artist
            # Datos del artista
            artist_data = {
              id: artist.spotify_id,
              name: artist.name,
              image_url: artist.image_url,
              genres: artist.genres,
              popularity: artist.popularity
            }
            
            # Álbumes del artista
            begin
              albums = MusicAlbum.where(artist_id: artist.spotify_id)
              albums_data = albums.map do |album|
                songs = Song.where(album: album.title)
                {
                  id: album.id.to_s,
                  title: album.title,
                  artist: artist.name,
                  coverUrl: album.image_url || album.cover_url, # Intentar ambos campos
                  releaseDate: album.release_date&.to_date&.to_s,
                  songsCount: songs.count
                }
              end
            rescue => e
              Rails.logger.error("Error obteniendo álbumes para el artista #{artist.name}: #{e.message}")
              albums_data = []
            end
            
            # Canciones del artista
            begin
              songs_data = Song.where(artist: artist.name).to_a
            rescue => e
              Rails.logger.error("Error obteniendo canciones para el artista #{artist.name}: #{e.message}")
              songs_data = []
            end
            
            # Devolver todos los datos en una única respuesta
            render json: {
              artist: artist_data,
              albums: albums_data,
              songs: songs_data
            }
          else
            render json: { error: "Artista no encontrado" }, status: :not_found
          end
        rescue => e
          Rails.logger.error("Error en el endpoint de detalles de artista: #{e.message}")
          render json: { error: "Error al procesar la solicitud: #{e.message}" }, status: :internal_server_error
        end
      end
      
    end
  end
end
