require "rails_helper"

RSpec.describe "/facturas", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { authenticated_header(user) }

  describe "POST /create" do
    it "creates a factura" do
      orden = create(:orden_fumigacion, :terminada)

      expect {
        post facturas_url,
             params: { factura: { orden_fumigacion_id: orden.id } },
             headers: valid_headers,
             as: :json
      }.to change(Factura, :count).by(1)

      factura = Factura.last
      expect(factura.orden_fumigacion_id).to eq(orden.id)
      expect(factura.fecha_factura).to be_present
    end

    it "returns errors with invalid params" do
      post facturas_url,
           params: { factura: { orden_fumigacion_id: nil } },
           headers: valid_headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["orden_fumigacion"]).to be_present
    end
  end
end
