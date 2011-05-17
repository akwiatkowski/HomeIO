class MemosController < ApplicationController
  #load_and_authorize_resource
  
  # GET /memos
  # GET /memos.xml
  def index
    @memos = Memo.all
    authorize! :read, Memo

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @memos }
    end
  end

  # GET /memos/1
  # GET /memos/1.xml
  def show
    @memo = Memo.find(params[:id])
    authorize! :read, Memo

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @memo }
    end
  end

  # GET /memos/new
  # GET /memos/new.xml
  def new
    @memo = Memo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @memo }
    end
  end

  # GET /memos/1/edit
  def edit
    #@memo = Memo.find(params[:id])
  end

  # POST /memos
  # POST /memos.xml
  def create
    @memo = Memo.new(params[:memo])
    @memo.user_id = current_user.id

    respond_to do |format|
      if @memo.save
        format.html { redirect_to(@memo, :notice => 'Memo was successfully created.') }
        format.xml  { render :xml => @memo, :status => :created, :location => @memo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @memo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /memos/1
  # PUT /memos/1.xml
  def update
    @memo = Memo.find(params[:id])
    @memo.user_id = current_user.id

    respond_to do |format|
      if @memo.update_attributes(params[:memo])
        format.html { redirect_to(@memo, :notice => 'Memo was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @memo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /memos/1
  # DELETE /memos/1.xml
  def destroy
    @memo = Memo.find(params[:id])
    @memo.destroy

    respond_to do |format|
      format.html { redirect_to(memos_url) }
      format.xml  { head :ok }
    end
  end
end
