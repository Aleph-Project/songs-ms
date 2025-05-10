class SpotifyImporterService
  def self.import_albums(album_names)
    results = []
    errors = []

    album_names.each do |album_name|
      begin
        # Buscar el álbum en Spotify
        spotify_albums = RSpotify::Album.search(album_name, limit: 1)
        
        if spotify_albums.empty?
          errors << "No se encontró el álbum: #{album_name}"
          next
        end
        
        spotify_album = spotify_albums.first
        
        # Importar canciones del álbum
        spotify_album.tracks.each do |track|
          # Comprobar si ya existe la canción
          existing_song = Song.where(title: track.name, album: spotify_album.name).first
          next if existing_song
          
          # Crear canción
          song = Song.new(
            title: track.name,
            artist: spotify_album.artists.first.name,
            authors: spotify_album.artists.map(&:name),
            album: spotify_album.name,
            release_date: spotify_album.release_date ? Date.parse(spotify_album.release_date) : Date.today,
            duration: format_duration(track.duration_ms),
            genre: track.artists.first.genres.first || "Unknown",
            likes: 0,
            plays: 0,
            cover_url: spotify_album.images.first["url"],
            audio_url: track.preview_url || "/audio/sample.mp3"
          )
          
          if song.save
            results << "Canción importada: #{song.title} - #{song.artist} (#{song.album})"
          else
            errors << "Error al guardar canción: #{song.title} - #{song.errors.full_messages.join(', ')}"
          end
        end
        
      rescue => e
        errors << "Error al importar álbum #{album_name}: #{e.message}"
      end
    end
    
    { results: results, errors: errors }
  end
  
  private
  
  def self.format_duration(duration_ms)
    total_seconds = duration_ms / 1000
    minutes = total_seconds / 60
    seconds = total_seconds % 60
    
    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
  end
end