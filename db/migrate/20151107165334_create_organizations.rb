class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :avatar
      t.string :aasm_state

      t.timestamps null: false
    end
  end
end
