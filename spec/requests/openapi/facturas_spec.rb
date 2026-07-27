require "swagger_helper"

RSpec.describe "Facturas API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  let(:Authorization) { authenticated_header(user)["Authorization"] }

  path "/facturas" do
    post "Crea una factura" do
      tags "Facturas"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/FacturaRequest" }

      response "201", "factura creada" do
        let(:ordenes) { create_list(:orden_fumigacion, 2, :terminada) }
        let(:payload) do
          {
            nro_factura: "FAC-001",
            ordenes_fumigacion: ordenes.map.with_index do |orden, index|
              {
                id: orden.id,
                importe: (100.25 + index).to_s,
                nro_orden_cliente: "ORD-#{index + 1}"
              }
            end
          }
        end

        schema "$ref" => "#/components/schemas/Factura"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            ordenes_fumigacion: []
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/facturas/{id}" do
    parameter name: :id, in: :path, type: :integer

    patch "Actualiza fecha de pago de una factura" do
      tags "Facturas"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/FacturaUpdateRequest" }

      response "204", "factura actualizada" do
        let(:id) { create(:factura, fecha_pago: nil).id }
        let(:payload) do
          {
            fecha_pago: "2026-01-20"
          }
        end

        run_test!
      end

      response "422", "fecha_pago requerida" do
        let(:id) { create(:factura, fecha_pago: nil).id }
        let(:payload) { {} }

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end
end
