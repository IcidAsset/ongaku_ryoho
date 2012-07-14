class Favourite < ActiveRecord::Base
  attr_accessible :track_artist, :track_title
  belongs_to :user
  
  validates_presence_of :track_artist
  validates_presence_of :track_title
end