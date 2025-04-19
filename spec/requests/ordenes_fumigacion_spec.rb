require 'rails_helper'

RSpec.describe "/ordenes_fumigacion", type: :request do
  let(:user) { create(:user) }

  let(:valid_attributes) {
    orden = build(:orden_fumigacion)
    orden.as_json.merge!(
      "dosis_attributes" => orden.dosis.map {|d| d.as_json.slice("producto_id", "cantidad") }
    )
  }

  let(:orden_sin_dosis) {
    build(:orden_fumigacion).as_json
  }

  let(:new_attributes) {
    { creado_por: "carlos" }
  }

  let(:invalid_attributes) {
    { creado_por: nil }
  }

  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "renders a successful response" do
      OrdenFumigacion.create! valid_attributes
      get ordenes_fumigacion_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      orden_fumigacion = OrdenFumigacion.create! valid_attributes
      get orden_fumigacion_url(orden_fumigacion), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do

      it "creates a new OrdenFumigacion" do
        expect {
          post ordenes_fumigacion_url,
               params: { orden_fumigacion: valid_attributes }, headers: valid_headers, as: :json
        }.to change(OrdenFumigacion, :count).by(1)
      end

      it "renders a JSON response with the new orden_fumigacion" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new OrdenFumigacion" do
        expect {
          post ordenes_fumigacion_url,
               params: { orden_fumigacion: invalid_attributes }, as: :json
        }.to change(OrdenFumigacion, :count).by(0)
      end

      it "does not create a new OrdenFumigacion sin dosis" do
        expect {
          post ordenes_fumigacion_url,
               params: { orden_fumigacion: orden_sin_dosis }, as: :json
        }.to change(OrdenFumigacion, :count).by(0)
      end

      it "renders a JSON response with errors for the new orden_fumigacion" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      

      it "updates the requested orden_fumigacion" do
        orden_fumigacion = OrdenFumigacion.create! valid_attributes
        patch orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: new_attributes }, headers: valid_headers, as: :json
        orden_fumigacion.reload
        expect(orden_fumigacion.creado_por).to eq("carlos")
      end

      it "renders a JSON response with the orden_fumigacion" do
        orden_fumigacion = OrdenFumigacion.create! valid_attributes
        patch orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the orden_fumigacion" do
        orden_fumigacion = OrdenFumigacion.create! valid_attributes
        patch orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested orden_fumigacion" do
      orden_fumigacion = OrdenFumigacion.create! valid_attributes
      expect {
        delete orden_fumigacion_url(orden_fumigacion), headers: valid_headers, as: :json
      }.to change(OrdenFumigacion, :count).by(-1)
    end
  end
end
