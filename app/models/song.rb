class Song
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  field :artist, type: String
  field :authors, type: Array, default: []
  field :album, type: String
  field :release_date, type: Date
  field :duration, type: String
  field :genre, type: String
  field :likes, type: Integer, default: 0
  field :plays, type: Integer, default: 0
  field :cover_url, type: String
  
  # GridFS audio file fields
  field :audio_file_id, type: BSON::ObjectId
  field :audio_filename, type: String
  field :audio_content_type, type: String
  field :audio_size, type: Integer
  field :audio_fingerprint, type: String
  
  field :spotify_id, type: String
  field :album_id, type: String

  # Validaciones
  validates :title, presence: true
  validates :artist, presence: true
  validates :album, presence: true
  validates :release_date, presence: true
  validates :duration, presence: true
  validates :genre, presence: true
  
  # Índices para búsquedas eficientes
  index({ title: 1 })
  index({ artist: 1 })
  index({ album: 1 })
  index({ genre: 1 })
  index({ spotify_id: 1 })
  index({ album_id: 1 })
  index({ audio_fingerprint: 1 })
  index({ audio_file_id: 1 })

  def audio_file=(file)
    return unless file

    # Delete old file if exists
    if audio_file_id
      Mongo::Grid::File.delete(audio_file_id)
    end

    # Store new file
    grid_fs = Mongo::Grid::FSBucket.new(Mongoid.default_client.database)
    
    # Upload the file and get the id
    file_id = grid_fs.upload_from_stream(
      file.original_filename,
      file.tempfile,
      content_type: file.content_type
    )
    
    self.audio_file_id = file_id
    self.audio_filename = file.original_filename
    self.audio_content_type = file.content_type
    self.audio_size = file.size
    self.audio_fingerprint = generate_audio_fingerprint(file.tempfile)
  end

  def audio_file
    return nil unless audio_file_id
    
    grid_fs = Mongo::Grid::FSBucket.new(Mongoid.default_client.database)
    stream = grid_fs.open_download_stream(audio_file_id)
    stream.read
  end

  private

  def generate_audio_fingerprint(tempfile)
    Digest::MD5.hexdigest(File.read(tempfile.path))
  end
end
