require "rails_helper"

RSpec.describe "/facturas_pago", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "returns facturas pendientes with ordenes and lotes" do
      estancia = create(:estancia, nombre: "Estancia 1")
      lote = create(:lote, estancia: estancia, nombre: "Lote 1", hectareas: 12.3)
      orden = create(:orden_fumigacion, :terminada, lotes: [ lote ])
      factura = create(:factura, ordenes_fumigacion: [ orden ], fecha_factura: Time.zone.local(2026, 1, 10), nro_factura: "FAC-2026")
      factura_orden = factura.facturas_ordenes_fumigacion.first
      factura_orden.update!(importe: 123.5, nro_orden_cliente: "ORD-100")

      create(:factura, fecha_pago: Time.zone.local(2026, 1, 11))
      factura_sin_fecha = create(:factura)
      factura_sin_fecha.update_column(:fecha_factura, nil)

      get facturas_pago_index_url, headers: valid_headers

      expect(response).to have_http_status(:ok)
      expect(json_response).to eq([
        {
          "id" => factura.id,
          "fecha_factura" => "2026-01-10T00:00:00.000Z",
          "fecha_factura_ddmmyyyy" => "10/01/2026",
          "nro_factura" => "FAC-2026",
          "ordenes_fumigacion" => [
            {
              "id" => orden.id,
              "importe" => "123.5",
              "nro_orden_cliente" => "ORD-100",
              "nombre_estancia" => "Estancia 1",
              "lotes" => [
                {
                  "nombre" => "Lote 1",
                  "hectareas" => "12.3"
                }
              ]
            }
          ]
        }
      ])
      expect(json_response.first).not_to have_key("fecha_pago")
    end
  end

end
