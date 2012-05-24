class Favourite
  include Mongoid::Document
  include Mongoid::Timestamps

  field :track_title,      type: String
  field :track_artist,     type: String

  embedded_in :user

end
