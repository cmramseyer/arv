class ApplicationController < ActionController::API
  include ActionController::Cookies

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
end
