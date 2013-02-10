class CreateSources < ActiveRecord::Migration
  def up
    create_table :sources do |t|
      t.boolean :activated, default: false
      t.hstore :configuration

      t.string :status, default: ""
      t.string :name

      t.string :type
      t.references :user

      t.timestamps
    end

    add_index :sources, :user_id

    execute <<-EOS
      CREATE INDEX sources_gin_configuration ON sources USING gin(configuration)
    EOS
  end

  def down
    drop_table :sources
  end
end
