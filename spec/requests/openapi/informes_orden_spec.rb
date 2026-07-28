require "swagger_helper"

RSpec.describe "Informe Orden API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { authenticated_header(user)["Authorization"] }

  path "/informe_orden" do
    get "Genera el informe mensual de órdenes terminadas" do
      tags "Informes"
      produces "application/pdf"
      security [ bearerAuth: [] ]

      parameter name: :mes, in: :query, type: :integer, required: true
      parameter name: :anio, in: :query, type: :integer, required: true

      response "200", "informe generado" do
        let(:mes) { 7 }
        let(:anio) { 2026 }

        before do
          create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2026, 7, 12))
        end

        run_test!
      end

      response "422", "período inválido" do
        let(:mes) { 13 }
        let(:anio) { 2026 }

        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        run_test!
      end
    end
  end
end
