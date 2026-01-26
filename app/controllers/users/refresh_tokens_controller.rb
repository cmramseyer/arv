class Users::RefreshTokensController < ApplicationController
  include RefreshCookie

  skip_before_action :authenticate_user!

  def create
    payload = refresh_cookie_payload

    unless payload.is_a?(Hash)
      delete_refresh_cookie
      return render json: { error: "Invalid refresh token" }, status: :unauthorized
    end

    user_id = payload["user_id"] || payload[:user_id]
    token = payload["token"] || payload[:token]
    jti = payload["jti"] || payload[:jti]

    user = User.find_by(id: user_id)

    unless user&.refresh_token_valid?(token, jti)
      user&.clear_refresh_token!
      delete_refresh_cookie
      return render json: { error: "Invalid refresh token" }, status: :unauthorized
    end

    new_token, new_jti = user.rotate_refresh_token!
    set_refresh_cookie(user_id: user.id, token: new_token, jti: new_jti, expires_at: user.refresh_token_expires_at)

    access_token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

    render json: { token: access_token }, status: :ok
  end
end
