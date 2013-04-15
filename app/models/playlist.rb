class Playlist < ActiveRecord::Base
  attr_accessible :name
  attr_accessor :special

  belongs_to :user

  has_many :playlists_tracks
  has_many :tracks, through: :playlists_tracks, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
end
