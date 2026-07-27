class Users::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_signed_out_user, only: :destroy

  include RefreshCookie

  def destroy
    respond_to_on_destroy
  end

  private

  def respond_with(resource, _opts = {})
    token, jti = resource.generate_refresh_token!
    set_refresh_cookie(user_id: resource.id, token: token, jti: jti, expires_at: resource.refresh_token_expires_at)

    render json: {
      message: "Logged in successfully.",
      user: resource,
      token: request.env["warden-jwt_auth.token"]
    }, status: :ok
  end

  def respond_to_on_destroy
    current_user&.clear_refresh_token!
    delete_refresh_cookie
    head :no_content
  end
end
