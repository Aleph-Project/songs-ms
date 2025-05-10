class MusicAlbum
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :spotify_id, type: String
  field :artist_id, type: String  # ID de referencia al artista
  field :release_date, type: Date
  field :total_tracks, type: Integer
  field :image_url, type: String
  field :album_type, type: String  # album, single, compilation

  # Relaciones
  belongs_to :music_artist, foreign_key: :artist_id, optional: true
  has_many :songs, foreign_key: :album_id

  # Validaciones
  validates :title, presence: true
  validates :spotify_id, presence: true, uniqueness: true
  validates :artist_id, presence: true

  # Índices para búsquedas eficientes
  index({ title: 1 })
  index({ spotify_id: 1 }, { unique: true })
  index({ artist_id: 1 })
  index({ album_type: 1 })

  # Métodos de instancia
  def to_s
    title
  end

  # Buscar álbum por id de Spotify o crear uno nuevo
  def self.find_or_create_by_spotify_id(spotify_id, album_data)
    album = where(spotify_id: spotify_id).first
    return album if album.present?

    # Crear nuevo álbum si no existe
    album = create!(
      spotify_id: spotify_id,
      title: album_data[:name],
      artist_id: album_data.dig(:artists, 0, :id),
      release_date: album_data[:release_date].present? ? Date.parse(album_data[:release_date]) : nil,
      total_tracks: album_data[:total_tracks],
      image_url: album_data[:image_url], # Ya recibimos la URL directamente
      album_type: album_data[:album_type]
    )

    Rails.logger.info("Álbum creado con éxito. ID: #{album.id}, Título: #{album.title}, Imagen: #{album.image_url}")
    album
  end
end
