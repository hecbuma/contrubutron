class ChangeLimitPayload < ActiveRecord::Migration
  def change
    change_column :pull_requests, :payload, :text, :limit => 1073741823
  end
end
