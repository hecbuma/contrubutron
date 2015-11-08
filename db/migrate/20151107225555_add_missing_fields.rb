class AddMissingFields < ActiveRecord::Migration
  def change
    add_column :repositories, :stars, :integer
    add_column :repositories, :watchers, :integer
    add_column :repositories, :forks, :integer
    add_column :pull_requests, :url, :string
    add_column :pull_requests, :comments, :integer
    add_column :pull_requests, :review_comments, :integer
    add_column :pull_requests, :additions, :integer
    add_column :pull_requests, :deletions, :integer
    add_column :pull_requests, :changed_files, :integer
  end
end
