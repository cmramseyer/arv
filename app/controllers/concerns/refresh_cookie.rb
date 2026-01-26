module RefreshCookie
  extend ActiveSupport::Concern

  private

  def refresh_cookie_payload
    cookies.encrypted[:refresh_token]
  end

  def set_refresh_cookie(user_id:, token:, jti:, expires_at:)
    cookies.encrypted[:refresh_token] = {
      value: {
        user_id: user_id,
        token: token,
        jti: jti
      },
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      expires: expires_at,
      path: "/refresh"
    }
  end

  def delete_refresh_cookie
    cookies.delete(:refresh_token, path: "/refresh")
  end
end
