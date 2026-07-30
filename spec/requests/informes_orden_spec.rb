require "rails_helper"

RSpec.describe "/informe_orden", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { authenticated_header(user) }

  describe "GET /informe_orden" do
    it "includes only terminated orders with maquinista in the requested month" do
      maquinista = create(:maquinista)
      orden_incluida = create(
        :orden_fumigacion,
        :terminada,
        maquinista: maquinista,
        fecha_trabajo: Date.new(2026, 7, 12)
      )
      create(:orden_fumigacion, :activa, maquinista: maquinista, fecha_trabajo: Date.new(2026, 7, 12))
      create(:orden_fumigacion, :terminada, maquinista: nil, fecha_trabajo: Date.new(2026, 7, 12))
      create(:orden_fumigacion, :terminada, maquinista: maquinista, fecha_trabajo: Date.new(2026, 8, 1))

      allow(InformeOrden).to receive(:new).and_wrap_original do |method, ordenes, **arguments|
        expect(ordenes.map(&:id)).to eq([ orden_incluida.id ])
        method.call(ordenes, **arguments)
      end

      get informe_orden_url, params: { mes: 7, anio: 2026 }, headers: valid_headers

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with("application/pdf")
      expect(response.body).to start_with("%PDF")
      expect(response.headers["Content-Disposition"]).to include("informe_orden_07_2026.pdf")
      expect(Rails.root.join("storage", "informe_orden_07_2026.pdf")).to exist
    end

    it "validates mes and anio" do
      get informe_orden_url, params: { mes: 13, anio: 2026 }, headers: valid_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response).to eq("error" => "mes y anio deben ser valores válidos")
    end
  end
end
