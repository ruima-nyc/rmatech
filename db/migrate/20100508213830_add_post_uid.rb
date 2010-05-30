class AddPostUid < ActiveRecord::Migration
  def self.up
    add_column :posts, :uid, :string,:null => false
  end

  def self.down
    remove_column :posts,:uid
  end
end
