require 'rails_helper'

RSpec.describe "/cultivos", type: :request do
  let(:user) { create(:user) }

  let(:valid_attributes) { build(:cultivo).attributes }

  let(:invalid_attributes) {
    { nombre: nil }
  }

  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "renders a successful response" do
      Cultivo.create! valid_attributes
      get cultivos_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      cultivo = Cultivo.create! valid_attributes
      get cultivo_url(cultivo), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Cultivo" do
        expect {
          post cultivos_url,
               params: { cultivo: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Cultivo, :count).by(1)
      end

      it "renders a JSON response with the new cultivo" do
        post cultivos_url,
             params: { cultivo: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Cultivo" do
        expect {
          post cultivos_url,
               params: { cultivo: invalid_attributes }, headers: valid_headers, as: :json
        }.to change(Cultivo, :count).by(0)
      end

      it "renders a JSON response with errors for the new cultivo" do
        post cultivos_url,
             params: { cultivo: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { nombre: 'nuevo cultivo' }
      }

      it "updates the requested cultivo" do
        cultivo = Cultivo.create! valid_attributes
        patch cultivo_url(cultivo),
              params: { cultivo: new_attributes }, headers: valid_headers, as: :json
        cultivo.reload
        expect(cultivo.nombre).to eq('nuevo cultivo')
      end

      it "renders a JSON response with the cultivo" do
        cultivo = Cultivo.create! valid_attributes
        patch cultivo_url(cultivo),
              params: { cultivo: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the cultivo" do
        cultivo = Cultivo.create! valid_attributes
        patch cultivo_url(cultivo),
              params: { cultivo: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested cultivo" do
      cultivo = Cultivo.create! valid_attributes
      expect {
        delete cultivo_url(cultivo), headers: valid_headers, as: :json
      }.to change(Cultivo, :count).by(-1)
    end
  end
end
