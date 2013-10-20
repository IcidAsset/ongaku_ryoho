class AddIdToPlaylistsTracks < ActiveRecord::Migration
  def up
    add_column :playlists_tracks, :id, :primary_key
  end

  def down
    remove_column :playlists_tracks, :id
  end
end
