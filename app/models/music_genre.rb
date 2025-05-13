class MusicGenre
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :slug, type: String
  field :count, type: Integer, default: 0

  # Relaciones
  has_and_belongs_to_many :music_artists, inverse_of: nil

  # Validaciones
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # Índices
  index({ name: 1 }, { unique: true })
  index({ slug: 1 }, { unique: true })

  before_validation :generate_slug

  # Métodos de instancia
  def to_s
    name
  end

  # Buscar género por nombre o crear uno nuevo
  def self.find_or_create_by_name(name)
    genre_name = name.strip.capitalize
    genre = where(name: genre_name).first
    return genre if genre.present?

    # Si no existe, crear uno nuevo
    Rails.logger.info("Creando nuevo género musical: #{genre_name}")
    create!(name: genre_name)
  end

  private

  # Generar slug a partir del nombre
  def generate_slug
    if self.name.present? && (self.slug.blank? || self.name_changed?)
      self.slug = self.name.parameterize
    end
  end
end