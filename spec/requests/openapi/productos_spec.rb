require "swagger_helper"

RSpec.describe "Productos API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  let(:Authorization) { authenticated_header(user)["Authorization"] }

  path "/productos" do
    get "Lista productos" do
      tags "Productos"

      produces "application/json"

      security [ bearerAuth: [] ]

      response "200", "productos encontrados" do
        before do
          create(:producto)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/Producto" }

        run_test!
      end
    end
  end
end
