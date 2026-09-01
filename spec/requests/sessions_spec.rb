require "rails_helper"

RSpec.describe "Browser sessions", type: :request do
  let(:password) { "password123" }
  let(:user) { create(:user, password:) }

  before { host! "localhost" }

  around do |example|
    original_setting = ApplicationController.allow_forgery_protection
    ApplicationController.allow_forgery_protection = true
    example.run
  ensure
    ApplicationController.allow_forgery_protection = original_setting
  end

  it "authenticates through an HttpOnly SameSite session cookie and requires CSRF for login and logout" do
    get "/session"

    expect(response).to have_http_status(:ok)
    expect(json_response).to include("authenticated" => false, "user" => nil)
    csrf_token = json_response.fetch("csrf_token")

    post "/login", params: { user: { email: user.email, password: } }, as: :json
    expect(response).to have_http_status(:unauthorized)

    post "/login",
         params: { user: { email: user.email, password: } },
         headers: { "X-CSRF-Token" => csrf_token },
         as: :json

    expect(response).to have_http_status(:ok)
    expect(json_response).to eq(
      "authenticated" => true,
      "user" => { "id" => user.id, "email" => user.email, "username" => user.username }
    )
    expect(response.headers.fetch("set-cookie")).to include("_arv_session")
    expect(response.headers.fetch("set-cookie")).to include("httponly")
    expect(response.headers.fetch("set-cookie")).to include("samesite=lax")

    get "/session"
    expect(response).to have_http_status(:ok)
    expect(json_response).to include("authenticated" => true)
    csrf_token = json_response.fetch("csrf_token")

    delete "/logout"
    expect(response).to have_http_status(:unauthorized)

    get "/session"
    csrf_token = json_response.fetch("csrf_token")

    post "/login",
         params: { user: { email: user.email, password: } },
         headers: { "X-CSRF-Token" => csrf_token },
         as: :json
    get "/session"

    delete "/logout", headers: { "X-CSRF-Token" => json_response.fetch("csrf_token") }
    expect(response).to have_http_status(:no_content)

    get "/productos"
    expect(response).to have_http_status(:unauthorized)
  end
end
