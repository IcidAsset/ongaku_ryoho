class AddPositionToPlaylistsTracks < ActiveRecord::Migration
  def change
    add_column :playlists_tracks, :position, :integer, default: 0
  end
end
