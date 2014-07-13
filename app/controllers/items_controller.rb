class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  add_breadcrumb :index, :items_path

  # GET /items
  # GET /items.json
  def index
    @items = current_user.items.root.files
  end

  # GET /items/1
  # GET /items/1.json
  def show
    if @item.is_a? FolderItem
      @items = @item.children.files
      add_item_parent_to_breadcrumb(@item)
      render action: :index
    else
      redirect_to @item.preview_url
    end

  end

  # GET /items/new
  def new
    @item = Item.new
    @item.parent = Item.find(params[:root]) if params[:root]
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    start_byte, end_byte, full_bytes = content_range_params

    if start_byte > 0
      @item = current_user.items.by_path(full_item_path).first
    else
      if parent_item.nil?
        @item = Item.new
      else
        @item = parent_item.children.new
      end

      @item.assign_attributes(path: full_item_path,
                              mime_type: item_content_type,
                              accounts: current_user.accounts.with_available_bytes(full_bytes),
                              file_size: full_bytes)
    end

    @item.write_content(item_params[:content].first, start_byte..end_byte)

    @items = [@item]

    respond_to do |format|
      if @item.save
        format.html { redirect_to items_path, notice: 'Item was successfully created.' }
        format.json { render }
        
      else
        format.html { render :new }
        format.json { render :json => [{:error => "custom_failure"}], :status => 304 }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      @item_params ||= params.require(:item).permit(:parent_item_id, content: [])
    end

    def add_item_parent_to_breadcrumb(item)
      add_item_parent_to_breadcrumb(item.parent) if item.parent
      add_breadcrumb item.name, item_path(item)
    end

    def content_range_params
      if request.headers["Content-Range"]
        /bytes (\d+)-(\d+)\/(\d+)/.match(request.headers["Content-Range"])[1..3].map {|i| i.to_i}
      else
        [0, item_params[:content].first.size-1, item_params[:content].first.size]
      end
    end

    def full_item_path
      path = ""
      path << parent_item.path if parent_item
      path << "/"
      path << item_params[:content].first.original_filename
      path
    end

    def item_content_type
      item_params[:content].first.content_type
    end

    def parent_item
      @parent_item ||= unless item_params[:parent_item_id].blank?
                         Item.find(item_params[:parent_item_id])
                       else
                         nil
                       end
    end
end
