class PlaylistsTrack < ActiveRecord::Base
  attr_accessible :track_id, :playlist_id, :position

  belongs_to :playlist
  belongs_to :track

  default_scope order("position ASC")

  #
  #  JSON
  #
  def as_json(options={})
    { id: self.track.id, position: position }
  end

end
