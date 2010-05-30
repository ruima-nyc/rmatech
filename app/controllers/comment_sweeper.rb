class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  def after_create(comment)
    #expire_cache_for(comment)
  end
  
  # If our sweeper detects that a comment was updated call this
  def after_update(comment)
    expire_cache_for(comment)
  end
  
  # If our sweeper detects that a comment was deleted call this
  def after_destroy(comment)
    expire_cache_for(comment)
  end
          
  private
  def expire_cache_for(record)

     expire_action :controller => 'posts', :action => 'index'
     expire_action :controller => 'posts', :action => 'show', :id => record.commentable
  

  end
end