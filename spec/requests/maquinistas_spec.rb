require 'rails_helper'

RSpec.describe "/maquinistas", type: :request do
  let(:user) { create(:user) }

  let(:valid_attributes) { build(:maquinista).attributes }

  let(:invalid_attributes) {
    { nombre: nil }
  }

  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "renders a successful response" do
      Maquinista.create! valid_attributes
      get maquinistas_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      maquinista = Maquinista.create! valid_attributes
      get maquinista_url(maquinista), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Maquinista" do
        expect {
          post maquinistas_url,
               params: { maquinista: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Maquinista, :count).by(1)
      end

      it "renders a JSON response with the new maquinista" do
        post maquinistas_url,
             params: { maquinista: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Maquinista" do
        expect {
          post maquinistas_url,
               params: { maquinista: invalid_attributes }, headers: valid_headers, as: :json
        }.to change(Maquinista, :count).by(0)
      end

      it "renders a JSON response with errors for the new maquinista" do
        post maquinistas_url,
             params: { maquinista: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { nombre: 'nuevo maquinista' }
      }

      it "updates the requested maquinista" do
        maquinista = Maquinista.create! valid_attributes
        patch maquinista_url(maquinista),
              params: { maquinista: new_attributes }, headers: valid_headers, as: :json
        maquinista.reload
        expect(maquinista.nombre).to eq('nuevo maquinista')
      end

      it "renders a JSON response with the maquinista" do
        maquinista = Maquinista.create! valid_attributes
        patch maquinista_url(maquinista),
              params: { maquinista: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the maquinista" do
        maquinista = Maquinista.create! valid_attributes
        patch maquinista_url(maquinista),
              params: { maquinista: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested maquinista" do
      maquinista = Maquinista.create! valid_attributes
      expect {
        delete maquinista_url(maquinista), headers: valid_headers, as: :json
      }.to change(Maquinista, :count).by(-1)
    end
  end
end
