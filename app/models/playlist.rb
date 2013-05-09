class Playlist < ActiveRecord::Base
  attr_accessible :name, :special
  attr_accessor :special

  belongs_to :user

  has_many :playlists_tracks
  has_many :tracks, through: :playlists_tracks, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  def tracks_with_position
    if self.special then []
    else self.playlists_tracks end
  end

  def track_ids
    tracks_with_position.map(&:track_id)
  end

end
