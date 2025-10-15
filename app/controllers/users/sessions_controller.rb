# frozen_string_literal: true

class Users::SessionsController < Devise::Passwordless::SessionsController
  # Use the default devise-passwordless behavior
  # The create method is handled by the parent class

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
