class SessionController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render json: {
      authenticated: current_user.present?,
      user: current_user ? session_user(current_user) : nil,
      csrf_token: form_authenticity_token
    }
  end
end
