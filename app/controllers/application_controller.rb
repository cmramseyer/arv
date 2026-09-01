class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  self.allow_forgery_protection = Rails.application.config.action_controller.allow_forgery_protection
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_token

  protected

  def handle_invalid_token
    render json: { error: "Invalid or missing CSRF token" }, status: :unauthorized
  end

  def authenticate_user!
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def session_user(user)
    user.slice(:id, :email, :username)
  end
end
