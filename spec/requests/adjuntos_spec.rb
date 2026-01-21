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
        [ "sample_file.png", "sample_file.jpg", "sample_file.png" ]
      )
    end

    it "validates required params" do
      get adjuntos_url, headers: valid_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("orden_fumigacion_id es requerido")
    end
  end

  describe "DELETE /lotes/:lote_id/adjuntos/:id" do
    it "destroys the requested adjunto" do
      lote = create(:lote)
      lote.adjuntos.attach(file_png)
      adjunto = lote.adjuntos.first

      expect do
        delete lote_adjunto_url(lote_id: lote.id, id: adjunto.id), headers: valid_headers
      end.to change { lote.adjuntos.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 if lote not found" do
      lote = create(:lote)
      lote.adjuntos.attach(file_png)
      adjunto = lote.adjuntos.first

      delete lote_adjunto_url(lote_id: 99999, id: adjunto.id), headers: valid_headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 if adjunto not found" do
      lote = create(:lote)

      delete lote_adjunto_url(lote_id: lote.id, id: 99999), headers: valid_headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /lotes/:lote_id/adjuntos" do
    it "creates a new adjunto for the lote" do
      lote = create(:lote)

      expect do
        post lote_adjuntos_url(lote_id: lote.id), params: { adjunto: file_png }, headers: valid_headers
      end.to change { lote.adjuntos.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(json_response.keys).to match_array(%w[id filename url])
      expect(json_response["filename"]).to eq("sample_file.png")
    end

    it "returns 404 if lote not found" do
      post lote_adjuntos_url(lote_id: 99999), params: { adjunto: file_png }, headers: valid_headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
