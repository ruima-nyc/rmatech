class FeedBacksController < ApplicationController
   before_filter :require_admin,:except => [:new,:create]
   skip_before_filter :verify_authenticity_token, :only => [:create]
  # GET /feed_backs
  # GET /feed_backs.xml
  def index
    @feed_backs = FeedBack.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feed_backs }
    end
  end

  # GET /feed_backs/1
  # GET /feed_backs/1.xml
  def show
    @feed_back = FeedBack.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feed_back }
    end
  end

  # GET /feed_backs/new
  # GET /feed_backs/new.xml
  def new
    @feed_back = FeedBack.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feed_back }
    end
  end

  # GET /feed_backs/1/edit
  def edit
    @feed_back = FeedBack.find(params[:id])
  end

  # POST /feed_backs
  # POST /feed_backs.xml
  def create
    @feed_back = FeedBack.new(params[:feed_back])
    respond_to do |format|
      if @feed_back.save
        flash[:notice] = '感谢你的建议.'
        format.html { redirect_to('/') }
      else
        flash[:notice] = '添加失败.'
        format.html { redirect_to('/') }
      end
    end
  end

  # PUT /feed_backs/1
  # PUT /feed_backs/1.xml
  def update
    @feed_back = FeedBack.find(params[:id])

    respond_to do |format|
      if @feed_back.update_attributes(params[:feed_back])
        flash[:notice] = 'FeedBack was successfully updated.'
        format.html { redirect_to(@feed_back) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feed_back.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feed_backs/1
  # DELETE /feed_backs/1.xml
  def destroy
    @feed_back = FeedBack.find(params[:id])
    @feed_back.destroy

    respond_to do |format|
      format.html { redirect_to(feed_backs_url) }
      format.xml  { head :ok }
    end
  end
end
