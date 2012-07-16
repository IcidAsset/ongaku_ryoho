class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.boolean :activated, default: false
      t.string :configuration, default: {}.to_yaml
      
      t.string :status, default: ""
      t.string :name
      
      t.string :type
      t.integer :user_id
      
      t.timestamps
    end
    
    add_index :sources, :user_id
  end

  def self.down
    drop_table :sources
  end
end
