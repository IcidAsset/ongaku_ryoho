class AddSortingIndexToTracks < ActiveRecord::Migration
  def up
    add_index :tracks, [:artist, :album, :tracknr, :title], unique: false, name: 'sorting_index'
  end

  def down
    remove_index :tracks, name: 'sorting_index'
  end
end
