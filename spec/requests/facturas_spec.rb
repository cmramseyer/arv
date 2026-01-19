require "rails_helper"

RSpec.describe "/facturas", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { authenticated_header(user) }

  describe "POST /create" do
    it "creates a factura" do
      ordenes = create_list(:orden_fumigacion, 2, :terminada)
      ordenes_params = ordenes.map.with_index do |orden, index|
        { id: orden.id, importe: 100.25 + index }
      end

      expect {
        post facturas_url,
             params: { ordenes_fumigacion: ordenes_params, nro_factura: "FAC-001" },
             headers: valid_headers,
             as: :json
      }.to change(Factura, :count).by(1)

      factura = Factura.last
      expect(factura.ordenes_fumigacion).to match_array(ordenes)
      facturas_ordenes = factura.facturas_ordenes_fumigacion
      expect(facturas_ordenes.map(&:importe)).to match_array([ 100.25.to_d, 101.25.to_d ])
      expect(factura.nro_factura).to eq("FAC-001")
      expect(factura.fecha_factura).to be_present
    end

    it "accepts nro_orden_cliente in ordenes_fumigacion" do
      orden = create(:orden_fumigacion, :terminada)

      post facturas_url,
           params: {
             ordenes_fumigacion: [
               { id: orden.id, importe: 50.0, nro_orden_cliente: "ORD-200" }
             ]
           },
           headers: valid_headers,
           as: :json

      expect(response).to have_http_status(:created)
      factura_orden = Factura.last.facturas_ordenes_fumigacion.first
      expect(factura_orden.nro_orden_cliente).to eq("ORD-200")
    end

    it "returns errors with invalid params" do
      post facturas_url,
           params: { ordenes_fumigacion: [] },
           headers: valid_headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["ordenes_fumigacion"]).to be_present
    end
  end
end
