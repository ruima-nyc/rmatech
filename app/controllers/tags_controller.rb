class TagsController < ApplicationController
  before_filter :require_admin,:except => [:show]
  
  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  def show
    @tag = Tag.find_by_name(params[:id])
    
    @posts = Post.paginate(:page => params[:page],:include =>  [:tags],:conditions => ["tags.id = ?",@tag.id],:order => "posts.hits DESC")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        flash[:notice] = '感谢你的提交.'
        format.html { redirect_back_or_default('/') }
        format.xml  { render :xml => @tag }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find_by_name(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def update
    @tag = Tag.find_by_name(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'tag was successfully updated.'
        format.html { redirect_to(@tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find_by_name(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
  
end
