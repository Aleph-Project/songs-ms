class MusicGenre
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :slug, type: String
  field :category, type: String # Categoría a la que pertenece el género
  field :count, type: Integer, default: 0 # Contador de artistas que tienen este género
  
  # Validaciones
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  
  # Antes de validar, creamos el slug
  before_validation :set_slug
  
  # Relaciones con otros modelos
  has_and_belongs_to_many :music_artists, inverse_of: :music_genres
  
  # Callback para actualizar el contador al agregar/quitar artistas
  after_save :update_count
  
  # Método de clase para buscar o crear un género por nombre
  def self.find_or_create_by_name(name)
    # Normalizar el nombre (minúsculas)
    normalized_name = name.downcase.strip
    
    # Buscar por nombre normalizado
    genre = where(name: normalized_name).first
    
    # Si no existe, crearlo
    unless genre
      # Determinar la categoría basada en el nombre
      category = determine_category(normalized_name)
      
      # Crear el nuevo género
      genre = create!(
        name: normalized_name,
        slug: normalized_name.parameterize,
        category: category
      )
    end
    
    genre
  end
  
  # Determina la categoría basada en el nombre del género
  def self.determine_category(genre_name)
    # Mapeo simplificado de géneros a categorías
    mappings = {
      # Pop
      /pop|synth|electropop|k-pop|dance pop|post-britpop/ => "Pop",
      
      # Hip Hop
      /hip hop|hip-hop|rap|trap|boom bap|underground|east coast|west coast|hardcore|latin hip hop|freestyle/ => "Hip Hop",
      
      # Rock
      /rock|indie rock|alternative|punk|hard rock|classic rock|noise rock|experimental|art rock|progressive|post-punk|psychedelic|folk rock/ => "Rock",
      
      # Electrónica
      /electro|techno|house|dance|ambient|idm|trance|drum/ => "Electrónica",
      
      # R&B
      /r&b|soul|funk|contemporary/ => "R&B",
      
      # Latina
      /reggaeton|latin|urban latin|salsa|bachata|merengue|cumbia/ => "Latina",
      
      # Indie
      /indie|shoegaze|dream pop/ => "Indie",
      
      # Metal
      /metal|heavy|death metal|black metal|thrash|nu metal|metalcore/ => "Metal",
      
      # Jazz
      /jazz|smooth jazz|bebop|fusion/ => "Jazz",
      
      # Clásica
      /classical|orchestra|piano|chamber|symphony/ => "Clásica"
    }
    
    # Buscar coincidencia en el mapeo
    category = "Otros" # Categoría por defecto
    
    mappings.each do |pattern, cat|
      if genre_name =~ pattern
        category = cat
        break
      end
    end
    
    category
  end
  
  # Método de clase para obtener categorías basadas en géneros existentes
  def self.categories
    categories = {}
    
    # Categorías predefinidas y sus colores
    category_colors = {
      'Pop' => 'from-pink-500 to-purple-500',
      'Hip Hop' => 'from-yellow-500 to-orange-500',
      'Rock' => 'from-red-500 to-red-800',
      'Electrónica' => 'from-blue-400 to-indigo-600',
      'R&B' => 'from-purple-400 to-purple-800',
      'Latina' => 'from-green-400 to-emerald-600',
      'Indie' => 'from-indigo-500 to-blue-800',
      'Jazz' => 'from-amber-400 to-yellow-800',
      'Metal' => 'from-gray-700 to-gray-900',
      'Clásica' => 'from-teal-400 to-teal-700',
      'Otros' => 'from-gray-400 to-gray-600'
    }
    
    # Organizar géneros por categoría
    MusicGenre.all.each do |genre|
      category_name = genre.category || 'Otros'
      
      if !categories[category_name]
        categories[category_name] = {
          id: category_name.parameterize,
          name: category_name,
          genres: [],
          color: category_colors[category_name] || 'from-gray-400 to-gray-600'
        }
      end
      
      categories[category_name][:genres] << {
        id: genre.id.to_s,
        name: genre.name,
        slug: genre.slug,
        count: genre.count
      }
    end
    
    # Convertir a array y ordenar por nombre
    categories.values.sort_by { |c| c[:name] }
  end
  
  private
  
  def set_slug
    self.slug ||= name.parameterize if name.present?
  end
  
  def update_count
    self.count = music_artists.count
    self.save if changed?
  end
end