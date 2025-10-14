# Controller for managing product comments with Hotwire Turbo Stream support
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_comment, only: [ :destroy ]

  # POST /products/:product_id/comments
  # Creates a new comment with Turbo Stream response
  # @return [turbo_stream] appends new comment to comments list
  # @return [turbo_stream] clears the comment form
  def create
    @comment = @product.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("comments_list", partial: "comments/comment", locals: { comment: @comment }),
            turbo_stream.replace("comment_form", partial: "comments/form", locals: { product: @product, comment: Comment.new })
          ]
        end
        format.html { redirect_to @product, notice: "Comment posted successfully!" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("comment_form", partial: "comments/form", locals: { product: @product, comment: @comment })
        end
        format.html { redirect_to @product, alert: "Failed to post comment." }
      end
    end
  end

  # POST /products/:product_id/comments/:id/toggle_upvote
  # Toggles upvote for a comment using Hotwire Turbo
  # @return [turbo_stream] updates the upvote button without page reload
  def toggle_upvote
    @comment = @product.comments.find(params[:id])

    if current_user.upvoted_comment?(@comment)
      # Remove upvote if already upvoted
      @comment.comment_upvotes.where(user: current_user).destroy_all
      @upvoted = false
    else
      # Create upvote
      @comment.comment_upvotes.create(user: current_user)
      @upvoted = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @product }
    end
  end

  # DELETE /products/:product_id/comments/:id
  # Removes a comment with Turbo Stream response
  # @return [turbo_stream] removes the comment from the DOM
  def destroy
    if @comment.user == current_user
      @comment.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("comment_#{@comment.id}") }
        format.html { redirect_to @product, notice: "Comment deleted successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_#{@comment.id}", partial: "comments/error", locals: { message: "You can only delete your own comments." }) }
        format.html { redirect_to @product, alert: "You can only delete your own comments." }
      end
    end
  end

  private

  # Sets the product for the comment
  def set_product
    @product = Product.find(params[:product_id])
  end

  # Sets the specific comment
  def set_comment
    @comment = @product.comments.find(params[:id])
  end

  # Strong parameters for comment creation
  def comment_params
    params.require(:comment).permit(:content)
  end
end
