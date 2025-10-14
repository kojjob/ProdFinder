# Controller for managing user profile settings and preferences
class SettingsController < ApplicationController
  before_action :authenticate_user!

  # GET /settings
  # Displays user settings form with current profile information
  # @return [User] the current user
  def index
    @user = current_user
    @notification_types = Notification.notification_types.keys
  end

  # PATCH/PUT /settings
  # Updates user profile settings and preferences
  # @return [User] the updated user on success
  # @return [User] the user with errors on failure
  def update
    @user = current_user

    # Handle account deletion
    if params[:delete_account] == "true"
      if params[:confirm_email] == @user.email
        @user.destroy
        redirect_to root_path, notice: "Your account has been successfully deleted. We're sad to see you go!"
        return
      else
        @notification_types = Notification.notification_types.keys
        flash.now[:error] = "Email confirmation does not match. Account not deleted."
        render :index, status: :unprocessable_entity
        return
      end
    end

    if @user.update(user_params)
      redirect_to settings_path, notice: "✨ Settings updated successfully!"
    else
      @notification_types = Notification.notification_types.keys
      render :index, status: :unprocessable_entity
    end
  end

  private

  # Strong parameters for user profile updates
  # @return [ActionController::Parameters] permitted profile parameters
  def user_params
    params.require(:user).permit(
      :email,
      :full_name,
      :username,
      :bio,
      :website_url,
      :twitter_handle,
      :github,
      :location,
      :country_code,
      :timezone,
      :email_notifications,
      :avatar
    )
  end
end
