class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :username
      t.string :email
      t.string :avatar

      t.timestamps null: false
    end
  end
end
