require "rails_helper"

RSpec.describe "CORS", type: :request do
  let(:frontend_origin) { Rails.application.credentials.cors_origins }

  it "allows credentialed requests only from the configured frontend origin" do
    options "/productos",
            headers: {
              "Origin" => frontend_origin,
              "Access-Control-Request-Method" => "POST",
              "Access-Control-Request-Headers" => "Content-Type, X-CSRF-Token"
            }

    expect(response.headers.fetch("access-control-allow-origin")).to eq(frontend_origin)
    expect(response.headers.fetch("access-control-allow-credentials")).to eq("true")
  end

  it "does not authorize an unconfigured origin" do
    options "/productos",
            headers: {
              "Origin" => "https://untrusted.example",
              "Access-Control-Request-Method" => "POST"
            }

    expect(response.headers).not_to have_key("access-control-allow-origin")
  end
end
