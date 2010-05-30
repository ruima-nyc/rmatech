class Feed < ActiveRecord::Base

 validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

  has_many :posts, :order => 'posts.updated_at', :dependent => :destroy do
    def last
      @last_post ||= find(:first, :order => 'posts.updated_at desc')
    end
  end

  def sync_feed(sync_remote = false)
  begin
    result = FeedFetcher::FeedFetcher.get_feed_source(url)
    if result
      #self.feed_url = result.url
      #self.title = result.title

      puts "TITLE: #{result.title}"
      self.title = result.title if self.title != result.title
      puts "DATE: #{result.last_update_at}"

      for article in result.articles
        #don't update post; just insert new one
        unless Post.find(:first,:conditions => [" title = ? and feed_id = ?", article.title, id])
          puts "\t NEW POST: #{article.title}\n"
          post = Post.new()
          post.title = article.title
          post.url = article.link
          post.body = article.content_encoded || article.description
          post.creator_id = owner_id
          post.feed_id = id
          post.uid = post.create_uid
          post.save
        end

        if (sync_remote)
          begin
            p = PostResource.new(:title => post.title, :url => post.url,:body => post.body,:salt => 'ilovemyfatboys')
            p.save
          rescue
             puts "Can't sync with remote server."
          end
        end
      end

    end

  rescue FeedFetcher::NoFeedForPageError
    @feed_error = "Sorry, we couldn't find a feed for this URL. Your blog needs to have a RSS feed facility for us to use it on Playful Bent."
    puts @feed_error
    return false
  rescue FeedFetcher::PageFeedError
    @feed_error = "You blog has a RSS feed, which is great. However, it doesn't work for us right now, which is less great. Sorry, this wont work."
    puts @feed_error
    return false
  rescue FeedFetcher::PageDoesntExistError
    @feed_error = "Are you sure you typed that right? We just tried to fetch that URL and we couldn't find anything there at all."
    puts @feed_error
    return false
  end

  self.last_sync_at = Time.now
  self.save
  return true
 end

end
