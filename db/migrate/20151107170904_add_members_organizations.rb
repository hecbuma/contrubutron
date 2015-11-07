class AddMembersOrganizations < ActiveRecord::Migration
  def change
    create_table :members_organizations do |t|
      t.integer :member_id
      t.integer :organization_id

    end
  end
end
