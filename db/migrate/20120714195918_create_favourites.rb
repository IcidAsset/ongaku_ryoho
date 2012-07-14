class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites do |t|
      t.string :track_artist
      t.string :track_title

      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :favourites
  end
end
