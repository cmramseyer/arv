module ApiHelper
  def authenticated_header(user)
    payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    token = payload[0]

    {
      'Authorization' => "Bearer #{token}"
    }
  end
end
