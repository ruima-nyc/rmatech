class AddUsersDesc < ActiveRecord::Migration
  def self.up
    add_column :users, :url, :string
    add_column :users, :desc, :text
  end

  def self.down
    remove_column :users, :url
    remove_column :users, :desc
  end
end
