require "rspotify"

class SpotifyService
  class AuthenticationError < StandardError; end

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret

    # Validación básica de credenciales
    if @client_id.nil? || @client_id.empty? || @client_id == "REEMPLAZAR_CON_TU_CLIENT_ID" ||
       @client_secret.nil? || @client_secret.empty? || @client_secret == "REEMPLAZAR_CON_TU_CLIENT_SECRET"
      raise AuthenticationError, "Se requieren credenciales válidas de Spotify. Revisa tu archivo spotify_credentials.yml."
    end

    # Validar que client_id y client_secret sean diferentes
    if @client_id == @client_secret
      raise AuthenticationError, "El client_id y client_secret no pueden ser iguales. Por favor revisa tus credenciales de Spotify."
    end

    # Autenticación con manejo de errores
    begin
      puts "Intentando autenticar con Spotify... (ID: #{@client_id[0, 4]}...)"
      RSpotify.authenticate(@client_id, @client_secret)
      puts "Autenticación exitosa con Spotify"
    rescue RestClient::BadRequest => e
      puts "Error de autenticación con Spotify: #{e.response}"
      begin
        error_details = JSON.parse(e.response.body)
        error_message = error_details["error_description"] || error_details["error"] || e.message
        raise AuthenticationError, "Error de autenticación con Spotify: #{error_message}. Verifica tus credenciales."
      rescue JSON::ParserError => json_error
        raise AuthenticationError, "Error de autenticación con Spotify. Código: #{e.http_code}. Verifica tus credenciales."
      end
    rescue StandardError => e
      puts "Error desconocido en la autenticación: #{e.class} - #{e.message}"
      raise AuthenticationError, "Error al conectar con Spotify: #{e.message}."
    end
  end

  # --- MÉTODOS PARA ARTISTAS ---

  # Buscar artistas por nombre
  def search_artists(query, limit = 10)
    begin
      RSpotify::Artist.search(query, limit: limit)
    rescue => e
      Rails.logger.error("Error buscando artistas en Spotify: #{e.message}")
      []
    end
  end

  # Obtener un artista por ID
  def get_artist_by_id(id)
    begin
      RSpotify::Artist.find(id)
    rescue => e
      Rails.logger.error("Error obteniendo artista de Spotify: #{e.message}")
      nil
    end
  end

  # Obtener varios artistas por IDs
  def get_several_artists(ids)
    begin
      RSpotify::Artist.find(ids)
    rescue => e
      Rails.logger.error("Error obteniendo múltiples artistas de Spotify: #{e.message}")
      []
    end
  end

  # Importar un artista a la base de datos
  def import_artist_to_database(artist)
    return nil if artist.nil?

    # Obtener la imagen del artista de mayor calidad
    artist_image_url = nil
    if artist.images.present?
      # Ordenamos por tamaño y tomamos la más grande para mayor calidad
      largest_image = artist.images.sort_by { |img| img["height"] || 0 }.last
      artist_image_url = largest_image["url"] if largest_image
      Rails.logger.info("Imagen del artista encontrada: #{artist_image_url}")
    else
      Rails.logger.warn("El artista no tiene imágenes disponibles")
    end

    # Buscar si el artista ya existe o crear uno nuevo
    artist_data = {
      name: artist.name,
      genres: artist.genres,
      popularity: artist.popularity,
      images: artist.images
    }

    # Añadimos la URL de la imagen directamente
    if artist_image_url
      artist_data[:image_url] = artist_image_url
    end

    MusicArtist.find_or_create_by_spotify_id(artist.id, artist_data)
  end

  # --- MÉTODOS PARA ÁLBUMES ---

  # Buscar álbumes por nombre
  def search_albums(query, limit = 10)
    begin
      RSpotify::Album.search(query, limit: limit)
    rescue => e
      Rails.logger.error("Error buscando álbumes en Spotify: #{e.message}")
      []
    end
  end

  # Obtener un álbum por ID
  def get_album_by_id(id)
    begin
      RSpotify::Album.find(id)
    rescue => e
      Rails.logger.error("Error obteniendo álbum de Spotify: #{e.message}")
      nil
    end
  end

  # Obtener varios álbumes por IDs
  def get_several_albums(ids)
    begin
      RSpotify::Album.find(ids)
    rescue => e
      Rails.logger.error("Error obteniendo múltiples álbumes de Spotify: #{e.message}")
      []
    end
  end

  # Obtener álbumes de un artista
  def get_artist_albums(artist_id, limit = 50, album_type = nil)
    begin
      artist = RSpotify::Artist.find(artist_id)
      artist.albums(limit: limit, album_type: album_type)
    rescue => e
      Rails.logger.error("Error obteniendo álbumes del artista: #{e.message}")
      []
    end
  end

  # Importar un álbum a la base de datos y asociarlo con su artista
  def import_album_to_database(album)
    # Verificar que el objeto album sea válido
    if album.nil? || !album.respond_to?(:name) || album.name.nil? || album.name.empty?
      Rails.logger.error("Error: Álbum inválido o sin nombre")
      return false
    end

    Rails.logger.info("Importando álbum: #{album.name} (#{album.id})")

    # Verificar que el álbum tenga artistas
    if !album.respond_to?(:artists) || album.artists.nil? || album.artists.empty?
      Rails.logger.error("Error: Álbum sin información de artistas")
      return false
    end

    # Importar el artista principal del álbum
    main_artist = album.artists.first
    db_artist = import_artist_to_database(main_artist)

    # Obtener la URL de la imagen del álbum
    album_image_url = nil
    if album.images.present?
      # Ordenamos por tamaño y tomamos la más grande para mayor calidad
      album_image = album.images.sort_by { |img| img["height"] || 0 }.last
      album_image_url = album_image["url"] if album_image
      Rails.logger.info("Imagen del álbum encontrada: #{album_image_url}")
    else
      Rails.logger.warn("El álbum no tiene imágenes disponibles")
    end

    # Crear el álbum en la base de datos
    album_data = {
      name: album.name,
      artists: [ { id: main_artist.id, name: main_artist.name } ],
      release_date: album.release_date,
      total_tracks: album.total_tracks || 0,
      image_url: album_image_url, # Pasar directamente la URL de la imagen
      album_type: album.album_type
    }

    db_album = MusicAlbum.find_or_create_by_spotify_id(album.id, album_data)

    # Si el álbum tiene tracks, importarlos
    if album.tracks.present?
      import_album_tracks(album, db_album, db_artist, album_image_url)
      return true
    end

    false
  end

  # Importar las canciones de un álbum
  def import_album_tracks(album, db_album, db_artist, album_cover_url)
    added_tracks = 0

    album.tracks.each do |track|
      begin
        # Verificar que el track tenga los datos esenciales
        if track.nil? || !track.respond_to?(:name) || track.name.nil? || track.name.empty?
          Rails.logger.warn("Advertencia: Track sin nombre, saltando...")
          next
        end

        # Crear una canción para cada track del álbum
        song = Song.where(spotify_id: track.id).first_or_initialize

        # Establecemos todos los campos necesarios
        song.title = track.name.presence || "Desconocido"
        song.artist = db_artist.name
        song.authors = track.artists.map(&:name)
        song.album = db_album.title
        song.album_id = db_album.id.to_s  # ID interno de MongoDB
        song.release_date = db_album.release_date || Date.today
        song.duration = format_duration(track.duration_ms)
        song.genre = determine_genre(track, db_artist)
        song.likes = rand(10000..500000) # Valores aleatorios para estadísticas
        song.plays = rand(50000..2000000)
        song.cover_url = album_cover_url || "/placeholder.svg?height=80&width=80"
        song.spotify_id = track.id

        # Guardar explícitamente la canción para asegurar que se guarde
        if song.save
          added_tracks += 1
          Rails.logger.info("Canción creada exitosamente: #{song.id} - #{song.title} con portada: #{song.cover_url}")
        else
          Rails.logger.error("Error al guardar la canción: #{song.errors.full_messages.join(', ')}")
        end
      rescue => e
        Rails.logger.error("Error al crear canción: #{e.message}")
        # Continuar con la siguiente canción si hay un error
      end
    end

    Rails.logger.info("Se importaron #{added_tracks} canciones del álbum '#{db_album.title}'")
    added_tracks > 0
  end

  # --- MÉTODOS PARA IMPORTACIÓN COMPLETA ---

  # Importar un artista con todos sus álbumes y canciones
  def import_artist_with_albums(artist_query, album_limit = 5)
    Rails.logger.info("Buscando artista: '#{artist_query}'")

    # Buscar artista
    artists = search_artists(artist_query, 1)
    if artists.empty?
      Rails.logger.info("No se encontraron artistas para la consulta: '#{artist_query}'")
      return {
        success: false,
        message: "No se encontró el artista '#{artist_query}'",
        artist: nil,
        albums_imported: 0,
        tracks_imported: 0
      }
    end

    artist = artists.first
    Rails.logger.info("Artista encontrado: #{artist.name} (#{artist.id})")

    # Importar el artista a la base de datos
    db_artist = import_artist_to_database(artist)

    # Obtener álbumes del artista
    albums = get_artist_albums(artist.id, album_limit)
    if albums.empty?
      Rails.logger.info("El artista '#{artist.name}' no tiene álbumes disponibles")
      return {
        success: false,
        message: "El artista '#{artist.name}' no tiene álbumes disponibles",
        artist: {
          name: db_artist.name,
          id: db_artist.spotify_id,
          image_url: db_artist.image_url
        },
        albums_imported: 0,
        tracks_imported: 0
      }
    end

    Rails.logger.info("Se encontraron #{albums.length} álbumes para el artista '#{artist.name}'")

    # Importar cada álbum
    albums_imported = 0
    tracks_imported = 0
    imported_albums = []

    albums.each do |album|
      # Verificar si el álbum ya existe
      existing_album = MusicAlbum.where(spotify_id: album.id).first
      if existing_album
        Rails.logger.info("El álbum '#{album.name}' ya existe en la base de datos")
        # Contar las canciones existentes para este álbum usando el ID interno de MongoDB
        existing_tracks = Song.where(album_id: existing_album.id.to_s).count
        tracks_imported += existing_tracks
        albums_imported += 1
        imported_albums << {
          name: existing_album.title,
          id: existing_album.spotify_id
        }
        next
      end

      # Cargar el álbum completo con tracks
      album_with_tracks = get_album_by_id(album.id)
      if album_with_tracks && import_album_to_database(album_with_tracks)
        db_album = MusicAlbum.where(spotify_id: album.id).first
        imported_albums << {
          name: db_album.title,
          id: db_album.spotify_id
        }
        albums_imported += 1
        tracks_imported += album_with_tracks.tracks.length
        Rails.logger.info("Álbum '#{album.name}' importado con #{album_with_tracks.tracks.length} canciones")
      end
    end

    # Retornar resultado
    {
      success: albums_imported > 0,
      message: albums_imported > 0 ?
        "Se importaron #{albums_imported} álbumes con #{tracks_imported} canciones del artista '#{artist.name}'" :
        "No se pudo importar ningún álbum del artista '#{artist.name}'",
      artist: {
        name: db_artist.name,
        id: db_artist.spotify_id,
        image_url: db_artist.image_url
      },
      albums_imported: albums_imported,
      tracks_imported: tracks_imported,
      albums: imported_albums
    }
  end

  # Importar álbumes según búsqueda
  def import_albums_by_query(query, limit = 5)
    Rails.logger.info("Buscando álbumes para la consulta: '#{query}' con límite: #{limit}")
    albums = search_albums(query, limit)

    result = { total: 0, albums: [], found: albums.length, skipped: [] }

    if albums.empty?
      Rails.logger.info("Spotify no devolvió ningún álbum para la consulta: '#{query}'")
      return result
    end

    Rails.logger.info("Spotify encontró #{albums.length} álbumes para la consulta: '#{query}'")
    albums.each_with_index do |album, index|
      Rails.logger.info("  #{index+1}. Procesando álbum: #{album.name} (#{album.id})")

      # Verificar si el álbum ya existe en la base de datos usando el ID de Spotify
      existing_album = MusicAlbum.where(spotify_id: album.id).first
      if existing_album
        Rails.logger.info("  - El álbum con ID '#{album.id}' ya existe en la base de datos. Saltando...")
        result[:skipped] << { name: album.name, reason: "already_exists" }
        next
      end

      # Cargar álbum completo con tracks
      album_with_tracks = get_album_by_id(album.id)
      if album_with_tracks && import_album_to_database(album_with_tracks)
        db_album = MusicAlbum.where(spotify_id: album.id).first
        # Verificar el número correcto de canciones importadas para este álbum
        track_count = Song.where(album_id: db_album.id.to_s).count
        Rails.logger.info("  ✅ Álbum '#{album.name}' importado exitosamente con #{track_count} canciones")
        result[:total] += 1
        result[:albums] << db_album.title
      else
        result[:skipped] << { name: album.name, reason: "import_failed" }
        Rails.logger.info("  ❌ No se pudo importar el álbum '#{album.name}'")
      end
    end

    Rails.logger.info("Resultados de importación: #{result[:total]} álbumes importados, #{result[:skipped].length} álbumes saltados")
    result
  end

  private

  def format_duration(duration_ms)
    total_seconds = duration_ms / 1000
    minutes = total_seconds / 60
    seconds = total_seconds % 60
    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
  end

  def determine_genre(track, artist)
    # Intentar determinar el género basado en el artista
    if artist.respond_to?(:genres) && artist.genres.any?
      artist.genres.first.capitalize
    else
      [ "Pop", "Rock", "Hip-hop", "R&B", "Electronic", "Latin", "Jazz" ].sample
    end
  rescue
    [ "Pop", "Rock", "Hip-hop", "R&B", "Electronic", "Latin", "Jazz" ].sample
  end
end
