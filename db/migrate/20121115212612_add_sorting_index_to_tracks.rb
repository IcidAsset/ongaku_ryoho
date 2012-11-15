class AddSortingIndexToTracks < ActiveRecord::Migration
  def self.up
    add_index :tracks, [:artist, :album, :tracknr, :title], unique: false, name: 'sorting_index'
  end

  def self.down
    remove_index :tracks, name: 'sorting_index'
  end
end
