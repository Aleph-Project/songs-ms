class MusicArtist
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :spotify_id, type: String
  field :genres, type: Array, default: []
  field :popularity, type: Integer
  field :image_url, type: String

  # Relaciones
  has_many :music_albums, foreign_key: :artist_id
  has_many :songs, foreign_key: :artist
  has_and_belongs_to_many :music_genres, inverse_of: nil

  # Validaciones
  validates :name, presence: true
  validates :spotify_id, presence: true, uniqueness: true

  # Índices para búsquedas eficientes
  index({ name: 1 })
  index({ spotify_id: 1 }, { unique: true })
  index({ genres: 1 })

  # Métodos de instancia
  def to_s
    name
  end

  # Buscar artista por id de Spotify o crear uno nuevo
  def self.find_or_create_by_spotify_id(spotify_id, artist_data)
    artist = where(spotify_id: spotify_id).first
    return artist if artist.present?

    # Extraer la URL de la imagen del artista
    image_url = nil
    if artist_data[:images].present?
      if artist_data[:images].is_a?(Array)
        # Si es un array de objetos, ordenar por tamaño y tomar el más grande
        image = artist_data[:images].sort_by { |img| img.is_a?(Hash) ? (img["height"] || 0) : 0 }.last
        image_url = image.is_a?(Hash) ? image["url"] : nil
      elsif artist_data[:images].is_a?(Hash) && artist_data[:images][:url]
        # Si es un objeto con url directa
        image_url = artist_data[:images][:url]
      end
    end

    Rails.logger.info("Creando artista: #{artist_data[:name]} con imagen: #{image_url || 'sin imagen'}")

    # Crear nuevo artista si no existe
    artist = create!(
      spotify_id: spotify_id,
      name: artist_data[:name],
      genres: artist_data[:genres] || [],
      popularity: artist_data[:popularity],
      image_url: image_url
    )

    Rails.logger.info("Artista creado con éxito. ID: #{artist.id}, Nombre: #{artist.name}, Imagen: #{artist.image_url}")
    
    # Actualizar géneros del artista
    artist.update_music_genres if artist.genres.present?
    
    artist
  end
  
  # Actualiza los géneros del artista en la colección MusicGenre
  def update_music_genres
    # Limpiar los géneros actuales
    self.music_genres.clear
    
    # Para cada género en el array de strings, buscar o crear el modelo MusicGenre
    self.genres.each do |genre_name|
      next if genre_name.blank?
      
      # Buscar o crear el género
      genre = MusicGenre.find_or_create_by_name(genre_name)
      
      # Asociar el género con este artista
      self.music_genres << genre unless self.music_genres.include?(genre)
    end
    
    # Guardar los cambios
    self.save
    
    Rails.logger.info("Géneros actualizados para el artista #{self.name}: #{self.genres.join(', ')}")
  end
end
