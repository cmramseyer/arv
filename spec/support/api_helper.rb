module ApiHelper
  def authenticated_header(user)
    sign_in user
    {}
  end
end
