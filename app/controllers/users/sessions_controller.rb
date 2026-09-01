class Users::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_signed_out_user, only: :destroy

  def destroy
    sign_out(resource_name)
    respond_to_on_destroy
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      authenticated: true,
      user: session_user(resource)
    }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end
end
