require 'rails_helper'

RSpec.describe "/productos", type: :request do
  let(:user) { create(:user) }

  let(:valid_attributes) { build(:producto).attributes }

  let(:invalid_attributes) {
    { nombre: 'producto', tipo_producto: '', unidad_medida: 1 }
  }

  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "renders a successful response" do
      Producto.create! valid_attributes
      get productos_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      producto = Producto.create! valid_attributes
      get producto_url(producto), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Producto" do
        expect {
          post productos_url,
               params: { producto: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Producto, :count).by(1)
      end

      it "renders a JSON response with the new producto" do
        post productos_url,
             params: { producto: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Producto" do
        expect {
          post productos_url,
               params: { producto: invalid_attributes }, as: :json
        }.to change(Producto, :count).by(0)
      end

      it "renders a JSON response with errors for the new producto" do
        post productos_url,
             params: { producto: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { nombre: 'producto2', unidad_medida: 1 }
      }

      it "updates the requested producto" do
        producto = Producto.create! valid_attributes
        patch producto_url(producto),
              params: { producto: new_attributes }, headers: valid_headers, as: :json
        producto.reload
        expect(Producto.last.nombre).to eq('producto2')
      end

      it "renders a JSON response with the producto" do
        producto = Producto.create! valid_attributes
        patch producto_url(producto),
              params: { producto: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the producto" do
        producto = Producto.create! valid_attributes
        patch producto_url(producto),
              params: { producto: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested producto" do
      producto = Producto.create! valid_attributes
      expect {
        delete producto_url(producto), headers: valid_headers, as: :json
      }.to change(Producto, :count).by(-1)
    end
  end
end
