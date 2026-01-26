class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :username, presence: true, uniqueness: true

  REFRESH_TOKEN_TTL = 14.days

  def generate_refresh_token!
    raw_token = SecureRandom.base58(64)
    jti = SecureRandom.uuid
    update!(
      refresh_token_digest: self.class.refresh_token_digest(raw_token),
      refresh_token_expires_at: REFRESH_TOKEN_TTL.from_now,
      refresh_token_jti: jti
    )

    [ raw_token, jti ]
  end

  def rotate_refresh_token!
    generate_refresh_token!
  end

  def refresh_token_valid?(raw_token, jti)
    return false if raw_token.blank? || jti.blank?
    return false if refresh_token_digest.blank? || refresh_token_jti.blank?
    return false if refresh_token_expires_at.blank? || Time.current >= refresh_token_expires_at

    digest = self.class.refresh_token_digest(raw_token)
    valid_digest = ActiveSupport::SecurityUtils.secure_compare(refresh_token_digest, digest)
    valid_jti = ActiveSupport::SecurityUtils.secure_compare(refresh_token_jti, jti)

    valid_digest && valid_jti
  end

  def clear_refresh_token!
    update!(refresh_token_digest: nil, refresh_token_expires_at: nil, refresh_token_jti: nil)
  end

  def self.refresh_token_digest(raw_token)
    OpenSSL::HMAC.hexdigest("SHA256", refresh_token_secret, raw_token)
  end

  def self.refresh_token_secret
    Rails.application.credentials.devise[:jwt_secret_key] || Rails.application.secret_key_base
  end
end
