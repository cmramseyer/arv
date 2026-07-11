require "swagger_helper"

RSpec.describe "Auth API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:password) { "password123" }
  let(:user) { create(:user, password: password) }

  path "/login" do
    post "Inicia sesion" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      security []

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/LoginRequest" }

      response "200", "sesion iniciada" do
        let(:payload) do
          {
            user: {
              email: user.email,
              password: password
            }
          }
        end

        schema "$ref" => "#/components/schemas/LoginResponse"

        run_test!
      end
    end
  end

  path "/logout" do
    delete "Cierra sesion" do
      tags "Auth"
      security [ bearerAuth: [] ]

      response "204", "sesion cerrada" do
        let(:Authorization) { authenticated_header(user)["Authorization"] }

        run_test!
      end
    end
  end

  path "/refresh" do
    post "Renueva el access token" do
      tags "Auth"
      produces "application/json"
      security []

      parameter name: :Cookie,
                in: :header,
                required: false,
                schema: { type: :string }

      response "200", "token renovado" do
        let(:Cookie) do
          token, jti = user.generate_refresh_token!
          request = ActionDispatch::Request.new(Rails.application.env_config)
          cookie_jar = ActionDispatch::Cookies::CookieJar.build(request, {})

          cookie_jar.encrypted[:refresh_token] = {
            value: {
              user_id: user.id,
              token: token,
              jti: jti
            },
            httponly: true,
            same_site: :lax,
            expires: user.refresh_token_expires_at,
            path: "/refresh"
          }

          cookie_jar.to_header
        end

        schema "$ref" => "#/components/schemas/RefreshResponse"

        run_test!
      end

      response "401", "refresh token invalido" do
        let(:Cookie) { nil }

        schema "$ref" => "#/components/schemas/ErrorMessage"

        run_test!
      end
    end
  end
end
