class PostsController < ApplicationController
  
  include Viewable
  before_filter :login_required, :except => [:show, :index,:rss,:new,:create,:bookmark,:update_views,:search]
  before_filter :login_or_vcode_required, :only => [:create]
  before_filter :require_admin, :only => [:edit,:update,:destroy,:queue,:publish,:unpublish,:preview]

  before_filter :setup_referring_keywords, :only => [:show]

  cache_sweeper :post_sweeper, :only => [:publish,:update_views]
  caches_action :rss
  #  caches_action :index, :if => Proc.new{|c| c.cache_action? }, :cache_path => Proc.new { |controller|
  #
  #    if controller.params[:page]
  #      if controller.params[:mobile] == "1"
  #        "#{HOST_URL}/posts?page=#{controller.params[:page]}&mobile=1"
  #      else
  #        "#{HOST_URL}/posts?page=#{controller.params[:page]}"
  #      end
  #    else
  #      if controller.params[:mobile] == "1"
  #        "#{HOST_URL}/posts?mobile=1"
  #      else
  #        "#{HOST_URL}/posts"
  #      end
  #    end
  #  }

  
  # caches_action :show, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && controller_name.eql?('posts')
  end
  
  
  def index
    @posts = Post.published.paginate(
      :page => params[:page],
      :order => 'publish_at DESC')

    @tags = Tag.all


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  def rss

    @posts = Post.published.find(:all,:order => 'created_at DESC',:limit => 20)
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"

  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    @tag = @post.tags[0]

    if @referring_search.size > 0
      @results = Post.search(@referring_search);
    else
      @results = @tag ? @tag.rand_posts : []
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
    @post.uid = @post.create_uid

    respond_to do |format|
      if @post.save
        flash[:notice] = '感谢你的提交.'
        format.html { redirect_to('/') }
        format.xml  { render :xml => @post }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def queue
    @posts = Post.unpublished.paginate(
      :page => params[:page],
      :order => 'created_at DESC')


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  def tagh
    @posts = Post.paginate(
      :page => params[:page],
      :order => 'publish_at ASC',
      :conditions => ['status = 2']
    )

   
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to(preview_post_path(@post)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    #Don't really delete it because feeder will fetch it again.
    #Just set to a unkown status
    @post.dispose

    respond_to do |format|
      format.html { redirect_to(queue_posts_url) }
      format.xml  { head :ok }
    end
  end

  def delete_selected

    if params[:delete] and params[:delete].is_a?(Array)
      params[:delete].each { |id|
        post = Post.find(id)
        #Don't really delete it because feeder will fetch it again.
        #Just set to a unkown status
        post.dispose
      }
      redirect_to(queue_posts_url) and return true
    else
      flash[:notice] = '请先选择要删除的文件'
      redirect_to :back
    end
  end

  def publish
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post])
    @post.publish(params[:history]==nil)

    respond_to do |format|
      format.html {
        if params[:history]
          redirect_to('/posts/tagh')
        else
          redirect_to(queue_posts_url)
        end
      }
      format.xml  { head :ok }
    end
  end

  def unpublish
    @post = Post.find(params[:id])
    @post.unpublish

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end

  def update_views
    @post = Post.find(params[:id])
    updated = update_view_count(@post)
    if params[:ret_url] and params[:ret_url] != ''
      redirect_to(params[:ret_url])
    else
      if params[:btn]
        render :partial => "posts/zan", :locals => {:viewable => @post,:zan => false,:btn => true}
      else
        render :partial => "posts/zan", :locals => {:viewable => @post,:zan => false,:btn => false}
      end
      
    end
    
  end

  def save
    @post = Post.find(params[:id])
    @user = current_user
    @user.posts << @post if @user and !@user.posts.include?(@post)
    if params[:ret_url] and params[:ret_url] != ''
      redirect_to(params[:ret_url])
    else
      render :text => params[:ret_url]
    end

  end

  def preview
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html  #preview.html.erb
      format.xml  { render :xml => @post }
    end
  end

  def search
    query = params[:search_text]
    @results = Post.search(query);
    
    respond_to do |format|
      format.html  #search.html.erb
      #format.xml  { render :xml => @posts }
    end
    
  end
  
  private

  def login_or_vcode_required
    if params[:imagecode]
      return session[:code] == params[:imagecode]
    elsif params[:post].is_a?(Hash) and params[:post][:salt] =='ilovemyfatboys'
      params[:post].delete(:salt)
      return true
    else
      login_required
    end
  end

  def setup_referring_keywords
    # Check whether referring URL was a search engine result
    referer = request.referer
    @referring_search = []
    unless referer.nil? or referer.empty?
      search_referers = [
        [/^http:\/\/(www\.)?google.*/, 'q'],
        [/^http:\/\/search\.yahoo.*/, 'p'],
        [/^http:\/\/search\.msn.*/, 'q'],
        [/^http:\/\/search\.aol.*/, 'userQuery'],
        [/^http:\/\/(www\.)?altavista.*/, 'q'],
        [/^http:\/\/(www\.)?feedster.*/, 'q'],
        [/^http:\/\/search\.lycos.*/, 'query'],
        [/^http:\/\/(www\.)?alltheweb.*/, 'q']
      ]
      query_args =
        begin
        URI.split(referer)[7]
      rescue URI::InvalidURIError
        nil
      end
      search_referers.each do |reg, query_param_name|
        # Check if the referrer is a search engine we are targetting
        if (reg.match(referer))

          # Highlight the Search Term Keywords on the page
          #@javascripts.push('keyword_highlighter')

          # Create a globally scoped variable (@referring_search) containing the referring Search Engine Query
          unless query_args.nil? or query_args.empty?
            query_args.split("&").each do |arg|
              pieces = arg.split('=')
              if pieces.length == 2 && pieces.first == query_param_name
                unstopped_keywords = CGI.unescape(pieces.last)
                stop_words = /\b(\d+|\w|about|after|also|an|and|are|as|at|be|because|before|between|but|by|can|com|de|do|en|for|from|has|how|however|htm|html|if|i|in|into|is|it|la|no|of|on|or|other|out|since|site:|site|such|than|that|the|there|these|this|those|to|under|upon|vs|was|what|when|where|whether|which|who|will|with|within|without|www|you|your)\b/i
                @referring_search = (unstopped_keywords.gsub(stop_words, '').squeeze(' '))
                logger.info("Referring Search Keywords: #{@referring_search}")
                return true
              end
            end
          end
          return true
        end
      end
    end
    true
  end

  
end
