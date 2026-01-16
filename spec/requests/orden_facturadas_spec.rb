require "rails_helper"

RSpec.describe "/orden_facturadas", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { authenticated_header(user) }

  describe "POST /create" do
    it "creates an orden_facturada" do
      orden = create(:orden_fumigacion, :terminada)

      expect {
        post orden_facturadas_url,
             params: { orden_facturada: { orden_fumigacion_id: orden.id } },
             headers: valid_headers,
             as: :json
      }.to change(OrdenFacturada, :count).by(1)

      orden_facturada = OrdenFacturada.last
      expect(orden_facturada.orden_fumigacion_id).to eq(orden.id)
      expect(orden_facturada.fecha_factura).to be_present
    end

    it "returns errors with invalid params" do
      post orden_facturadas_url,
           params: { orden_facturada: { orden_fumigacion_id: nil } },
           headers: valid_headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["orden_fumigacion"]).to be_present
    end
  end
end
