require "rails_helper"

RSpec.describe "/adjuntos", type: :request do
  let(:user) { create(:user) }
  let(:file_png) { fixture_file_upload("sample_file.png", "image/png") }
  let(:file_png_two) { fixture_file_upload("sample_file.png", "image/png") }
  let(:file_jpg) { fixture_file_upload("sample_file.jpg", "image/jpg") }
  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "returns adjuntos for the orden" do
      lote_uno = create(:lote)
      lote_dos = create(:lote)
      orden = create(:orden_fumigacion, lotes: [ lote_uno, lote_dos ])

      lote_uno.adjuntos.attach(file_png)
      lote_uno.adjuntos.attach(file_jpg)
      lote_dos.adjuntos.attach(file_png_two)

      get adjuntos_url, params: { orden_fumigacion_id: orden.id }, headers: valid_headers

      expect(response).to be_successful
      expect(json_response.size).to eq(3)
      expect(json_response.first.keys).to match_array(%w[id filename url])
      expect(json_response.map { |adjunto| adjunto["filename"] }).to match_array(
        ["sample_file.png", "sample_file.jpg", "sample_file.png"]
      )
    end

    it "validates required params" do
      get adjuntos_url, headers: valid_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("orden_fumigacion_id es requerido")
    end
  end
end
