class Track
  include Mongoid::Document

  field :title,      type: String
  field :artist,     type: String
  field :album,      type: String
  field :genre,      type: String

  field :tracknr,    type: Integer
  field :year,       type: Integer

  field :filename,   type: String
  field :location,   type: String
  field :url,        type: String

end
