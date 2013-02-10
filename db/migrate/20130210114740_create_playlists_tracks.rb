class CreatePlaylistsTracks < ActiveRecord::Migration
  def up
    create_table :playlists_tracks, id: false do |t|
      t.references :playlist
      t.references :track
    end

    add_index :playlists_tracks, :playlist_id
    add_index :playlists_tracks, :track_id
  end

  def down
    drop_table :playlists_tracks
  end
end
