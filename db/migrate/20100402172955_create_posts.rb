class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.string :url
      t.text :body
      t.integer :hits, :default => 0
      t.integer :creator_id
      t.integer :feed_id
      t.integer :status, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
