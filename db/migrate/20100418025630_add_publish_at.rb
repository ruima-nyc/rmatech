class AddPublishAt < ActiveRecord::Migration
  def self.up
    add_column :posts, :publish_at, :datetime
  end

  def self.down
    remove_column :posts,:publish_at
  end
end
