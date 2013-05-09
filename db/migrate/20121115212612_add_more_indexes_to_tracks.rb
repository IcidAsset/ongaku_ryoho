class AddMoreIndexesToTracks < ActiveRecord::Migration
  def up
    execute <<-EOS
      CREATE INDEX tracks_default_lookup_index ON tracks(id, source_id);
      CREATE INDEX tracks_sorting_default_index ON tracks(lower(artist), lower(album), tracknr, lower(title));
      CREATE INDEX tracks_sorting_title_index ON tracks(lower(title), tracknr, lower(artist), lower(album));
      CREATE INDEX tracks_sorting_album_index ON tracks(lower(album), tracknr, lower(artist), lower(title));
    EOS
  end

  def down
    remove_index :tracks, name: 'tracks_default_lookup_index'
    remove_index :tracks, name: 'tracks_sorting_default_index'
    remove_index :tracks, name: 'tracks_sorting_title_index'
    remove_index :tracks, name: 'tracks_sorting_album_index'
  end
end
