class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.string :nickname
      t.string :name
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :uid, :unique => true
  end
end
