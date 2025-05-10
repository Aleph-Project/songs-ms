module Api
  module V1
    class SpotifyController < ApplicationController
      # POST /api/v1/spotify/import_albums
      def import_albums
        # Verificar si se proporcionó una consulta
        return render json: { error: 'Se requiere un término de búsqueda' }, status: :bad_request unless params[:query].present?
        
        # Obtener las credenciales de Spotify de la configuración centralizada
        client_id = SPOTIFY_CONFIG[:client_id]
        client_secret = SPOTIFY_CONFIG[:client_secret]
        
        # Inicializar el servicio de Spotify
        spotify_service = SpotifyService.new(client_id, client_secret)
        
        # Importar álbumes según la consulta
        limit = params[:limit].present? ? params[:limit].to_i : 5
        result = spotify_service.import_albums_by_query(params[:query], limit)
        
        if result[:total] > 0
          render json: { 
            message: "Se importaron #{result[:total]} álbumes exitosamente", 
            albums: result[:albums]
          }, status: :ok
        else
          render json: { 
            message: "No se encontraron álbumes nuevos para importar con la consulta: #{params[:query]}"
          }, status: :ok
        end
      rescue => e
        render json: { error: "Error al importar álbumes: #{e.message}" }, status: :unprocessable_entity
      end
      
      # GET /api/v1/spotify/callback
      # Este endpoint es solo para cumplir con los requisitos de Spotify
      def callback
        render json: { message: "Autorización de Spotify completada" }, status: :ok
      end

      # POST /api/v1/spotify/import_artist
      def import_artist
        # Verificar si se proporcionó una consulta
        return render json: { error: 'Se requiere un nombre de artista' }, status: :bad_request unless params[:artist].present?
        
        # Obtener las credenciales de Spotify de la configuración centralizada
        client_id = SPOTIFY_CONFIG[:client_id]
        client_secret = SPOTIFY_CONFIG[:client_secret]
        
        # Inicializar el servicio de Spotify
        spotify_service = SpotifyService.new(client_id, client_secret)
        
        # Importar artista con sus álbumes
        album_limit = params[:album_limit].present? ? params[:album_limit].to_i : 5
        result = spotify_service.import_artist_with_albums(params[:artist], album_limit)
        
        if result[:success]
          render json: { 
            message: result[:message], 
            artist: result[:artist],
            albums_imported: result[:albums_imported],
            tracks_imported: result[:tracks_imported],
            albums: result[:albums]
          }, status: :ok
        else
          render json: { 
            message: result[:message],
            artist: result[:artist]
          }, status: :ok
        end
      rescue => e
        render json: { error: "Error al importar artista: #{e.message}" }, status: :unprocessable_entity
      end

      # POST /api/v1/spotify/import_album
      def import_album
        # Verificar si se proporcionó un ID de álbum
        return render json: { error: 'Se requiere el ID del álbum de Spotify' }, status: :bad_request unless params[:album_id].present?
        
        # Obtener las credenciales de Spotify de la configuración centralizada
        client_id = SPOTIFY_CONFIG[:client_id]
        client_secret = SPOTIFY_CONFIG[:client_secret]
        
        # Inicializar el servicio de Spotify
        spotify_service = SpotifyService.new(client_id, client_secret)
        
        # Verificar si el álbum ya existe en la base de datos
        existing_album = MusicAlbum.where(spotify_id: params[:album_id]).first
        if existing_album
          artist = MusicArtist.find(existing_album.artist_id) rescue nil
          
          return render json: { 
            message: "El álbum con ID '#{params[:album_id]}' ya existe en la base de datos.",
            album: {
              id: existing_album.spotify_id,
              title: existing_album.title,
              artist: artist&.name || "Desconocido",
              tracks_count: Song.where(album_id: existing_album.spotify_id).count
            }
          }, status: :ok
        end
        
        # Obtener el álbum específico de Spotify
        album = spotify_service.get_album_by_id(params[:album_id])
        
        if album.nil?
          return render json: { 
            message: "No se encontró el álbum con ID: #{params[:album_id]} en Spotify"
          }, status: :not_found
        end
        
        # Verificar que el álbum tenga artista
        if album.artists.nil? || album.artists.empty?
          return render json: { 
            message: "El álbum no tiene información de artista"
          }, status: :unprocessable_entity
        end
        
        # Obtener el artista principal y asegurarnos de que esté en la base de datos
        main_artist = album.artists.first
        
        # Intentar obtener el artista de la base de datos
        artist = MusicArtist.where(spotify_id: main_artist.id).first
        
        # Si el artista no existe, importarlo primero
        unless artist
          Rails.logger.info("Artista no encontrado en base de datos. Importando artista: #{main_artist.name}")
          
          # Obtener datos completos del artista de Spotify
          spotify_artist = spotify_service.get_artist_by_id(main_artist.id)
          
          if spotify_artist
            # Importar el artista a la base de datos
            artist = spotify_service.import_artist_to_database(spotify_artist)
            Rails.logger.info("Artista importado: #{artist.name}") if artist
          else
            Rails.logger.error("No se pudo obtener información completa del artista de Spotify")
          end
        end
        
        # Ahora intentar importar el álbum
        if spotify_service.import_album_to_database(album)
          db_album = MusicAlbum.where(spotify_id: params[:album_id]).first
          tracks_count = Song.where(album_id: params[:album_id]).count
          
          render json: { 
            message: "Se importó correctamente el álbum '#{album.name}'", 
            album: {
              id: db_album.spotify_id,
              title: db_album.title,
              artist: artist&.name || main_artist.name,
              tracks_count: tracks_count
            }
          }, status: :ok
        else
          render json: { 
            message: "No se pudo importar el álbum con ID: #{params[:album_id]}"
          }, status: :unprocessable_entity
        end
      rescue => e
        render json: { error: "Error al importar álbum: #{e.message}" }, status: :unprocessable_entity
      end

      # GET /api/v1/spotify/search_albums
      def search_albums
        # Verificar si se proporcionó una consulta
        return render json: { error: 'Se requiere un término de búsqueda' }, status: :bad_request unless params[:query].present?
        
        # Obtener las credenciales de Spotify
        client_id = SPOTIFY_CONFIG[:client_id]
        client_secret = SPOTIFY_CONFIG[:client_secret]
        
        # Inicializar el servicio de Spotify
        spotify_service = SpotifyService.new(client_id, client_secret)
        
        # Buscar álbumes según la consulta
        limit = params[:limit].present? ? params[:limit].to_i : 10
        result = spotify_service.search_albums(params[:query], limit)
        
        render json: { albums: result }, status: :ok
      rescue => e
        render json: { error: "Error al buscar álbumes: #{e.message}" }, status: :unprocessable_entity
      end
    end
  end
end