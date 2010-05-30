#require File.dirname(__FILE__) + '/../config/environment'

puts "Loading (Rails #{Rails.version})"

remote = (ARGV[0] and ARGV[0] == "remote")

puts "Sync Remote Resource: #{remote.to_s}"

#### main ####

previous_time = Time.at(0)

while(1)

  if ((Time.now - previous_time)/60).round < 15
    puts "Zzzz..."
    sleep(60)
    next
  else
    @feeds = Feed.find(:all)
    puts "Upading all #{@feeds.size} feeds..."
    for feed in (@feeds)

      if !feed.last_sync_at or ((Time.now - feed.last_sync_at)/60).round > 60
        puts "feed: #{feed.title} updated now." if feed.sync_feed(remote)
      else
        puts "feed: #{feed.title} just updated #{((Time.now - feed.last_sync_at)/60).round} mins ago."
      end
    end

    previous_time = Time.now


  end


end



