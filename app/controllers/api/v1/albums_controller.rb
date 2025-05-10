module Api
  module V1
    class AlbumsController < ApplicationController
      def index
        # Parámetro opcional para filtrar por artista
        if params[:artist_id].present?
          albums = MusicAlbum.where(artist_id: params[:artist_id])
        else
          albums = MusicAlbum.all
        end
        
        render json: albums.map { |album| album_to_json(album) }
      end
      
      def show
        album = MusicAlbum.find_by(id: params[:id]) || MusicAlbum.find_by(spotify_id: params[:id])
        
        if album
          render json: album_to_json(album)
        else
          render json: { error: "Álbum no encontrado" }, status: :not_found
        end
      end
      
      private
      
      def album_to_json(album)
        # Intentamos obtener el artista mediante la asociación directa
        artist = album.music_artist
        
        # Si no encontramos el artista por la asociación, buscamos en otros lugares
        if artist.nil? && album.artist_id.present?
          # Buscar por ID o spotify_id
          artist = MusicArtist.where(id: album.artist_id).first || 
                  MusicArtist.where(spotify_id: album.artist_id).first
        end
        
        # Buscar cualquier canción del álbum para obtener el nombre del artista como último recurso
        artist_name = if artist
                        artist.name
                      else
                        # Intentar obtener de las canciones asociadas
                        song = Song.where(album: album.title).first
                        song&.artist || "Artista Desconocido"
                      end
        
        songs = Song.where(album: album.title)
        songs_count = songs.count
        
        {
          id: album.id.to_s,
          spotify_id: album.spotify_id,
          title: album.title,
          artist: artist_name,
          artist_id: album.artist_id,
          release_date: album.release_date,
          total_tracks: album.total_tracks || songs_count,
          songs_count: songs_count,
          coverUrl: album.image_url || (songs.first&.cover_url),
          album_type: album.album_type
        }
      end
    end
  end
end