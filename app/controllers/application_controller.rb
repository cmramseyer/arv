class ApplicationController < ActionController::API
  
  before_action :authenticate_user!

  before_action :skip_session_storage

  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_token

  protected

  def handle_invalid_token
    render json: { error: 'Invalid or missing CSRF token' }, status: :unauthorized
  end

  def authenticate_user!
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  private

  def skip_session_storage
    request.session_options[:skip] = true
  end
end
