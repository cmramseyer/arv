require 'rails_helper'

RSpec.describe "/dosis", type: :request do
  let(:user) { create(:user) }

  let(:valid_attributes) {
    orden = create(:orden_fumigacion)
    lote_orden = orden.lote_ordenes_fumigacion.first

    {
      cantidad: rand(1..100),
      producto_id: create(:producto).id,
      lote_orden_fumigacion_id: lote_orden.id
    }
  }

  let(:invalid_attributes) {
    { cantidad: 0 }
  }

  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "renders a successful response" do
      Dosis.create! valid_attributes
      get dosis_index_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      dosis = Dosis.create! valid_attributes
      get dosis_url(dosis), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Dosis" do
        expect {
          post dosis_index_url,
               params: { dosis: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Dosis, :count).by(1)
      end

      it "renders a JSON response with the new dosis" do
        post dosis_index_url,
             params: { dosis: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Dosis" do
        expect {
          post dosis_index_url,
               params: { dosis: invalid_attributes }, as: :json
        }.to change(Dosis, :count).by(0)
      end

      it "renders a JSON response with errors for the new dosis" do
        post dosis_index_url,
             params: { dosis: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { cantidad: 1 }
      }

      it "updates the requested dosis" do
        dosis = Dosis.create! valid_attributes
        patch dosis_url(dosis),
              params: { dosis: new_attributes }, headers: valid_headers, as: :json
        dosis.reload
        expect(Dosis.last.cantidad).to eq(1)
      end

      it "renders a JSON response with the dosis" do
        dosis = Dosis.create! valid_attributes
        patch dosis_url(dosis),
              params: { dosis: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the dosis" do
        dosis = Dosis.create! valid_attributes
        patch dosis_url(dosis),
              params: { dosis: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested dosis" do
      dosis = Dosis.create! valid_attributes
      expect {
        delete dosis_url(dosis), headers: valid_headers, as: :json
      }.to change(Dosis, :count).by(-1)
    end
  end
end
