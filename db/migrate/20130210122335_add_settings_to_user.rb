class AddSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :settings, :text, default: {}.to_yaml
  end
end
