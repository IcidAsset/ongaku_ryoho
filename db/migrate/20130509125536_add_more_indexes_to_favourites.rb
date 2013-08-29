class AddMoreIndexesToFavourites < ActiveRecord::Migration
  def up
    execute <<-EOS
      CREATE INDEX favourites_default_lookup_index ON favourites(id, user_id);
      CREATE INDEX favourites_sorting_default_index ON favourites(lower(artist), lower(album), lower(title));
      CREATE INDEX favourites_sorting_title_index ON favourites(lower(title), lower(artist), lower(album));
      CREATE INDEX favourites_sorting_album_index ON favourites(lower(album), lower(artist), lower(title));
    EOS
  end

  def down
    remove_index :favourites, name: 'favourites_default_lookup_index'
    remove_index :favourites, name: 'favourites_sorting_default_index'
    remove_index :favourites, name: 'favourites_sorting_title_index'
    remove_index :favourites, name: 'favourites_sorting_album_index'
  end
end
