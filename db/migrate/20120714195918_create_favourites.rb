class CreateFavourites < ActiveRecord::Migration
  def up
    create_table :favourites do |t|
      t.string :artist
      t.string :title
      t.string :album
      t.string :genre

      t.integer :tracknr, default: 0
      t.integer :year

      t.string :filename
      t.string :location
      t.string :url

      t.references :user
      t.hstore :track_ids

      t.column :search_vector, 'tsvector'

      t.timestamps
    end

    add_index :favourites, :user_id

    execute <<-EOS
      CREATE INDEX favourites_gin_track_ids ON favourites USING gin(track_ids)
    EOS

    execute <<-EOS
      CREATE INDEX favourites_search_index ON favourites USING gin(search_vector)
    EOS

    execute <<-EOS
      CREATE TRIGGER favourites_vector_update BEFORE INSERT OR UPDATE
      ON favourites
      FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(
          search_vector, 'pg_catalog.english',
          artist, title, album
        );
    EOS
  end

  def down
    drop_table :favourites
  end
end
