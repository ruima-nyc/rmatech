require 'rss/1.0'
require 'rss/2.0'
require 'rss/content'
require 'open-uri'

module FeedFetcher
  class FeedSource
    attr_reader :url
    
    def initialize(new_url, new_title = '')
      @url = new_url
      @title = new_title
    end

    def title
      ensure_rss_loaded
      @title = @rss.channel.title || @title
    end
    
    def articles
      ensure_rss_loaded
      @rss.items if @rss
    end

    def last_update_at
      ensure_rss_loaded
      @rss.channel.date
    end
    
    def reload
      @rss = nil
    end
    
  protected
  
    def ensure_rss_loaded
      @rss = get_rss unless @rss
    end
    
    def get_rss
      content = PageFetcher.fetch_page(url)
      if content
        rss = RSS::Parser.parse(content, false)
        return rss
      else
        raise FeedSourceError
      end
    end
  
  end
end
