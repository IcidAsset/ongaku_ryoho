class CreatePlaylists < ActiveRecord::Migration
  def up
    create_table :playlists do |t|
      t.string :name

      t.references :user

      t.timestamps
    end

    add_index :playlists, :user_id
  end

  def down
    drop_table :playlists
  end
end
