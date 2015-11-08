class CreatePullRquests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.integer :member_id
      t.integer :repository_id
      t.text :payload
      t.string :state
      t.boolean :merged

      t.timestamps null: false
    end
  end
end
