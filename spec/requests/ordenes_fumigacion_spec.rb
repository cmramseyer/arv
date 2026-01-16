require 'rails_helper'

RSpec.describe "/ordenes_fumigacion", type: :request do
  let(:user) { create(:user) }

  let(:valid_attributes) {
    orden = build(:orden_fumigacion)
    orden.as_json.merge!(
      "dosis_attributes" => orden.dosis.map { |d| d.as_json.slice("producto_id", "cantidad") },
      "lote_ids" => orden.lotes.map(&:id)
    )
  }

  let(:valid_attributes_many_lotes) {
    orden = build(:orden_fumigacion, :many_lotes)
    orden.as_json.merge!(
      "dosis_attributes" => orden.dosis.map { |d| d.as_json.slice("producto_id", "cantidad") },
      "lote_ids" => orden.lotes.map(&:id)
    )
  }

  let(:valid_attributes_temp_info) {
    orden = build(:orden_fumigacion, :temp_info)
    orden.as_json.merge!(
      "dosis_attributes" => orden.dosis.map { |d| d.as_json.slice("producto_id", "cantidad") },
    )
  }

  let(:orden_sin_dosis) {
    build(:orden_fumigacion).as_json
  }

  let(:new_attributes) {
    { creado_por: "carlos" }
  }

  let(:atributos_terminada) {
    { info_trabajo: "info", maquinista: "juan", fecha_trabajo: Date.today }
  }

  let(:invalid_attributes) {
    { creado_por: nil }
  }

  let(:invalid_attributes_no_lote_no_temp_info) {
    orden = build(:orden_fumigacion, :temp_info)
    orden.temp_lotes = nil
    orden.as_json.merge!(
      "dosis_attributes" => orden.dosis.map { |d| d.as_json.slice("producto_id", "cantidad") }
    )
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
    context "with one lote" do
      it "renders a successful response" do
        orden_fumigacion = OrdenFumigacion.create! valid_attributes
        get orden_fumigacion_url(orden_fumigacion), headers: valid_headers, as: :json
        expect(response).to be_successful
      end
    end

    context "with many lotes" do
      it "renders a successful response" do
        orden_fumigacion = OrdenFumigacion.create! valid_attributes_many_lotes
        get orden_fumigacion_url(orden_fumigacion), headers: valid_headers, as: :json
        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters, one lote" do
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

    context "with valid parameters, many lotes" do
      it "creates a new OrdenFumigacion" do
        expect {
          post ordenes_fumigacion_url,
               params: { orden_fumigacion: valid_attributes_many_lotes }, headers: valid_headers, as: :json
        }.to change(OrdenFumigacion, :count).by(1)
      end

      it "renders a JSON response with the new orden_fumigacion" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: valid_attributes_many_lotes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with valid parameters, temp info" do
      it "creates a new OrdenFumigacion" do
        expect {
          post ordenes_fumigacion_url,
               params: { orden_fumigacion: valid_attributes_temp_info }, headers: valid_headers, as: :json
        }.to change(OrdenFumigacion, :count).by(1)
      end

      it "renders a JSON response with the new orden_fumigacion" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: valid_attributes_temp_info }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters, no lotes, no temp_lotes info" do
      it "creates a new OrdenFumigacion" do
        expect {
          post ordenes_fumigacion_url,
               params: { orden_fumigacion: invalid_attributes_no_lote_no_temp_info }, headers: valid_headers, as: :json
        }.to change(OrdenFumigacion, :count).by(0)
      end

      it "renders a JSON response with the new orden_fumigacion" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: invalid_attributes_no_lote_no_temp_info }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["base"][0]).to eq("Debe tener al menos un lote, o temp_lotes y temp_hectareas deben estar completos y temp_hectareas distinto de cero.")
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

  describe "PATCH /terminar" do
    context "with valid parameters" do
      it "termina orden_fumigacion" do
        orden_fumigacion = OrdenFumigacion.create! valid_attributes
        patch terminar_orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: atributos_terminada }, headers: valid_headers, as: :json
        orden_fumigacion.reload
        expect(orden_fumigacion.maquinista).to eq("juan")
        expect(orden_fumigacion.info_trabajo).to eq("info")
        expect(orden_fumigacion.fecha_trabajo).to eq(Date.today)
        expect(orden_fumigacion.estado_orden).to eq("terminada")
      end

      it "renders a JSON response with the orden_fumigacion" do
        orden_fumigacion = OrdenFumigacion.create! valid_attributes
        patch terminar_orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: atributos_terminada }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "con una orden ya terminada" do
      it "renders a JSON response with error" do
        orden_fumigacion = create(:orden_fumigacion, :terminada)
        patch terminar_orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: atributos_terminada }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(json_response["error"]).to eq("La orden ya está terminada")
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

  describe "POST /pendiente_factura" do
    it "returns agrupado por estancia" do
      estancia = create(:estancia, nombre: "Estancia 1")
      lote = create(:lote, estancia: estancia, hectareas: 22)
      orden = create(:orden_fumigacion, :terminada, lotes: [ lote ], fecha_trabajo: Date.new(2025, 10, 22))
      orden_facturada = create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2025, 10, 23))
      create(:orden_facturada, orden_fumigacion: orden_facturada, fecha_factura: Time.zone.now)
      create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2025, 11, 1))
      create(:orden_fumigacion, :activa, fecha_trabajo: Date.new(2025, 10, 22))

      post pendiente_factura_ordenes_fumigacion_url,
           params: { fecha_desde: "2025-10-01", fecha_hasta: "2025-10-31" },
           headers: valid_headers,
           as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response).to eq([
        {
          "id" => estancia.id,
          "nombre" => "Estancia 1",
          "data" => [
            {
              "lote_id" => lote.id,
              "hectareas" => lote.hectareas.to_s,
              "fecha_trabajo" => "2025-10-22",
              "maquinista" => orden.maquinista,
              "orden_id" => orden.id
            }
          ]
        }
      ])
    end

    it "validates required params" do
      post pendiente_factura_ordenes_fumigacion_url,
           params: { fecha_desde: "", fecha_hasta: "" },
           headers: valid_headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("fecha_desde y fecha_hasta son requeridas")
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
