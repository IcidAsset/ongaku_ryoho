class Favourite < ActiveRecord::Base
  attr_accessible :artist, :title, :album, :track_id

  belongs_to :user
  belongs_to :track

  validates_presence_of :artist
  validates_presence_of :title
  validates_presence_of :album
end
