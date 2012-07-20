class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :artist
      t.string :title
      t.string :album
      t.string :genre

      t.integer :tracknr
      t.integer :year

      t.string :filename
      t.string :location
      t.string :url

      t.integer :source_id
      t.integer :favourite_id

      t.column :search_vector, 'tsvector'

      t.timestamps
    end

    add_index :tracks, :source_id
    add_index :tracks, :favourite_id

    execute <<-EOS
      CREATE INDEX tracks_search_index ON tracks USING gin(search_vector)
    EOS

    execute <<-EOS
      CREATE TRIGGER tracks_vector_update BEFORE INSERT OR UPDATE
      ON tracks
      FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(
          search_vector, 'pg_catalog.english',
          artist, title, album
        );
    EOS
  end

  def self.down
    drop_table :tracks
  end
end
