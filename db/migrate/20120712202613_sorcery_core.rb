class SorceryCore < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.string :crypted_password, default: nil
      t.string :salt, default: nil

      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
