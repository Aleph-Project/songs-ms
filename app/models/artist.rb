class Artist
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :spotify_id, type: String
  field :image_url, type: String
  field :genres, type: Array
  field :popularity, type: Integer
end
