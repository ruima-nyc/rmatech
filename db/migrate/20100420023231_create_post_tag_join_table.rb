class CreatePostTagJoinTable < ActiveRecord::Migration
  def self.up
    create_table :posts_tags, :id => false do |t|
      t.integer :tag_id
      t.integer :post_id
    end
  end

  def self.down
    drop_table :posts_tags
  end
end
