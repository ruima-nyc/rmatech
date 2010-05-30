module FeedFetcher
  class PageFetcher
    def self.fetch_page(site_url_to_open)
      begin
        open(site_url_to_open,"User-Agent" => "RMA Tech FeedFetcher")
      rescue Exception
        nil
      end
    end
  end
end
