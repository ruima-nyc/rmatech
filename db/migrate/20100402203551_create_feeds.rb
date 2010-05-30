class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.string :title
      t.string :url
      t.integer :owner_id
      t.datetime :last_sync_at

      t.timestamps
    end

    a = Feed.new()
    a.url = "http://hi.baidu.com/caoz/rss"
    a.save
  end

  def self.down
    drop_table :feeds
  end
end
