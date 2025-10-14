class CollectionsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update ]
  before_action :set_collection, only: [ :show, :edit, :update ]

  def index
    @collections = Collection.includes(:user, :products).where(visibility: :public).order(created_at: :desc).page(params[:page])
  end

  def show
    @products = @collection.collection_products.includes(:product).order(position: :asc)
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = current_user.collections.build(collection_params)

    if @collection.save
      redirect_to @collection, notice: "Collection was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: "Collection was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_collection
    @collection = Collection.includes(:user, :products).find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :visibility)
  end
end
