require "rails_helper"

RSpec.describe "Browser sessions", type: :request do
  let(:password) { "password123" }
  let(:user) { create(:user, password:) }

  before { host! "localhost" }

  it "authenticates through an HttpOnly SameSite session cookie and clears it on logout" do
    post "/login", params: { user: { email: user.email, password: } }, as: :json

    expect(response).to have_http_status(:ok)
    expect(json_response).to eq(
      "authenticated" => true,
      "user" => { "id" => user.id, "email" => user.email, "username" => user.username }
    )
    expect(response.headers.fetch("set-cookie")).to include("_arv_session")
    expect(response.headers.fetch("set-cookie")).to include("httponly")
    expect(response.headers.fetch("set-cookie")).to include("samesite=lax")

    get "/productos"
    expect(response).to have_http_status(:ok)

    delete "/logout"
    expect(response).to have_http_status(:no_content)

    get "/productos"
    expect(response).to have_http_status(:unauthorized)
  end
end
