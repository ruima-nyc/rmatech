require 'drb/drb'

module Searcher
 
  SERVER_URI="druby://localhost:8788"
  DRb.start_service

  @@search_service=DRbObject.new_with_uri(SERVER_URI)

  def search(query)
    puts "query in client searcher::search method is " + query
    return @@search_service.search(query)
  end

end


#class CC_test
#  extend Searcher
#end
#
#query = "facebook"
#result_ids = CC_test.search(query)
#puts result_ids