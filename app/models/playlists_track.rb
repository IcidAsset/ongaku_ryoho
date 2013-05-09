class PlaylistsTrack < ActiveRecord::Base
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
