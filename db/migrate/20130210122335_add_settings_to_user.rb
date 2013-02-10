class AddSettingsToUser < ActiveRecord::Migration
  def up
    add_column :users, :settings, :hstore

    execute <<-EOS
      CREATE INDEX users_gin_settings ON users USING gin(settings)
    EOS
  end

  def down
    remove_column :users, :settings
  end
end
