class PostSweeper < ActionController::Caching::Sweeper
  observe Post # This sweeper is going to keep an eye on the Post model



  def after_update(post)

    if post.changes.has_key?('hits')
      expire_action :controller => 'posts', :action => 'show',:id => post
      controller.params[:page] ?
        expire_action(:controller => 'posts', :action => 'index', :page => params[:page]): expire_action(:controller => 'posts', :action => 'index')
    elsif post.changes.has_key?('status')
      expire_action :controller => 'posts', :action => 'rss'
      #adding/deleting a new post needs to refresh the whole paginate. RoR action cache sucks!
      total_page = (Float(Post.published.count)/Post.per_page).ceil
      p = 1
      begin
        p != 1 ?
        expire_action(:controller => 'posts', :action => 'index', :page => p): expire_action(:controller => 'posts', :action => 'index')
        p += 1
      end while p <= total_page
    end

    
      
        

  end
  
end