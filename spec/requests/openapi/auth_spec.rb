require "swagger_helper"

RSpec.describe "Auth API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:password) { "password123" }
  let(:user) { create(:user, password: password) }

  path "/login" do
    post "Inicia sesion" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

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

  path "/session" do
    get "Obtiene la sesion actual y el token CSRF" do
      tags "Auth"
      produces "application/json"
      security []

      response "200", "estado de sesion" do
        schema "$ref" => "#/components/schemas/SessionResponse"

        run_test!
      end
    end
  end

  path "/logout" do
    delete "Cierra sesion" do
      tags "Auth"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      before { sign_in user }

      response "204", "sesion cerrada" do
        run_test!
      end
    end
  end
end
