class Album
  include Mongoid::Document
  include Mongoid::Timestamps

  # Definir campos
  field :title, type: String
  field :artist, type: String
  field :release_date, type: Date
  field :spotify_id, type: String
  field :cover_image, type: String

  # Relaciones (si las hay)
  has_many :songs

  # Validaciones
  validates :title, presence: true
end
