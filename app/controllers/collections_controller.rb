# Controller for managing user product collections
# Handles creation, editing, and viewing of curated product lists
class CollectionsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update ]
  before_action :set_collection, only: [ :show, :edit, :update ]

  # GET /collections
  # Displays all public collections with pagination
  # @return [Array<Collection>] paginated public collections with user and products
  def index
    @collections = Collection.includes(:user, :products).where(visibility: :public).order(created_at: :desc).page(params[:page])
  end

  # GET /collections/:id
  # Displays a specific collection with its products in order
  # @return [Collection] the requested collection
  # @return [Array<CollectionProduct>] products in the collection ordered by position
  def show
    @products = @collection.collection_products.includes(:product).order(position: :asc)
  end

  # GET /collections/new
  # Displays form for creating a new collection (authenticated users only)
  # @return [Collection] new collection instance
  def new
    @collection = Collection.new
  end

  # POST /collections
  # Creates a new collection for the current user
  # @return [Collection] the created collection on success
  # @return [Collection] the collection with errors on failure
  def create
    @collection = current_user.collections.build(collection_params)

    if @collection.save
      redirect_to @collection, notice: "Collection was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /collections/:id/edit
  # Displays form for editing an existing collection (owner only)
  # @return [Collection] the collection to edit
  def edit
  end

  # PATCH/PUT /collections/:id
  # Updates an existing collection (owner only)
  # @return [Collection] the updated collection on success
  # @return [Collection] the collection with errors on failure
  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: "Collection was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Finds and sets the collection by ID with user and products associations preloaded
  # @return [Collection] the found collection
  # @raise [ActiveRecord::RecordNotFound] if collection doesn't exist
  def set_collection
    @collection = Collection.includes(:user, :products).find(params[:id])
  end

  # Strong parameters for collection creation and updates
  # @return [ActionController::Parameters] permitted parameters
  def collection_params
    params.require(:collection).permit(:name, :description, :visibility)
  end
end
