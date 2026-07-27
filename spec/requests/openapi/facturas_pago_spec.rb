require "swagger_helper"

RSpec.describe "Facturas Pago API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  let(:Authorization) { authenticated_header(user)["Authorization"] }

  path "/facturas_pago" do
    get "Lista facturas pendientes de pago" do
      tags "Facturas Pago"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "facturas pendientes encontradas" do
        before do
          estancia = create(:estancia, nombre: "Estancia 1")
          lote = create(:lote, estancia: estancia, nombre: "Lote 1", hectareas: 12.3)
          orden = create(:orden_fumigacion, :terminada, lotes: [ lote ])
          factura = create(
            :factura,
            ordenes_fumigacion: [ orden ],
            fecha_factura: Date.new(2026, 1, 10),
            nro_factura: "FAC-2026"
          )

          factura.facturas_ordenes_fumigacion.first.update!(importe: 123.5, nro_orden_cliente: "ORD-100")
          create(:factura, fecha_pago: Date.new(2026, 1, 11))
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/FacturaPago" }

        run_test!
      end
    end
  end
end
