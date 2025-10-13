# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    # Use strong params
    sign_in_params = params.require(:user).permit(:email)

    # Validate email presence and format
    email = sign_in_params[:email].to_s.strip

    if email.blank?
      flash[:alert] = "Email address is required."
      return redirect_to new_user_session_path
    end

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      flash[:alert] = "Please enter a valid email address."
      return redirect_to new_user_session_path
    end

    # Find user and send passwordless link
    user = User.find_by(email: email)

    if user
      # Send passwordless magic link
      user.send_passwordless_link
      flash[:notice] = "Check your email for the magic link to sign in."
      redirect_to root_path
    else
      flash[:alert] = "Email not found. Please sign up first."
      redirect_to new_user_registration_path
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
