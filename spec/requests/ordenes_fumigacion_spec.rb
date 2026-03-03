require 'rails_helper'

RSpec.describe "/ordenes_fumigacion", type: :request do
  let(:user) { create(:user) }
  let(:maquinista) { create(:maquinista) }
  let(:file_png) { fixture_file_upload("sample_file.png", "image/png") }

  def response_ids
    expect(response).to have_http_status(:ok), response.body
    Array.wrap(json_response).map { |item| item["id"] }
  end

  let(:valid_attributes) {
    orden = build(:orden_fumigacion)
    orden.as_json.merge!(
      "cultivo_id" => orden.cultivo.id,
      "sensible" => true,
      "comentarios" => "Orden sensible",
      "lotes" => orden.lotes.map do |lote|
        {
          "lote_id" => lote.id,
          "dosis" => [
            {
              "producto_id" => create(:producto).id,
              "cantidad" => rand(1..100)
            }
          ]
        }
      end
    )
  }

  let(:valid_attributes_with_hectareas_reales) {
    orden = build(:orden_fumigacion)
    orden.as_json.merge!(
      "cultivo_id" => orden.cultivo.id,
      "sensible" => true,
      "comentarios" => "Orden sensible",
      "lotes" => orden.lotes.map do |lote|
        {
          "lote_id" => lote.id,
          "hectareas_reales" => 10.5,
          "dosis" => [
            {
              "producto_id" => create(:producto).id,
              "cantidad" => rand(1..100)
            }
          ]
        }
      end
    )
  }

  let(:valid_attributes_many_lotes) {
    orden = build(:orden_fumigacion, :many_lotes)
    orden.as_json.merge!(
      "cultivo_id" => orden.cultivo.id,
      "sensible" => true,
      "comentarios" => "Orden sensible",
      "lotes" => orden.lotes.map do |lote|
        {
          "lote_id" => lote.id,
          "dosis" => [
            {
              "producto_id" => create(:producto).id,
              "cantidad" => rand(1..100)
            }
          ]
        }
      end
    )
  }

  let(:orden_sin_dosis) {
    build(:orden_fumigacion).as_json
  }

  let(:new_attributes) {
    { info_trabajo: "updated info", sensible: true, comentarios: "Actualizado" }
  }

  let(:atributos_terminada) {
    { info_trabajo: "info", maquinista_id: maquinista.id, fecha_trabajo: Date.today }
  }

  let(:invalid_attributes) {
    { creator_id: nil }
  }

  let(:invalid_attributes_no_lotes) {
    orden = build(:orden_fumigacion, lotes: [])
    orden.as_json.merge!(
      "cultivo_id" => orden.cultivo.id,
      "sensible" => true,
      "comentarios" => "Orden sensible",
      "lotes" => []
    )
  }

  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "renders a successful response" do
      create(:orden_fumigacion)
      get ordenes_fumigacion_url, headers: valid_headers
      expect(response).to be_successful
    end

    it "includes facturas data when present" do
      orden_fumigacion = create(:orden_fumigacion)
      fecha_factura = Date.new(2026, 1, 10)
      fecha_pago = Date.new(2026, 1, 12)
      factura = create(:factura, ordenes_fumigacion: [], fecha_factura: fecha_factura, fecha_pago: fecha_pago, nro_factura: "FAC-2026")
      create(:facturas_ordenes_fumigacion, orden_fumigacion: orden_fumigacion, factura: factura, nro_orden_cliente: "ORD-100")

      get ordenes_fumigacion_url, headers: valid_headers

      orden_response = json_response.find { |item| item["id"] == orden_fumigacion.id }

      expect(orden_response["facturas"]).to eq([
        {
          "nro_factura" => "FAC-2026",
          "nro_orden_cliente" => "ORD-100",
          "fecha_factura" => fecha_factura.to_s,
          "fecha_pago" => fecha_pago.to_s
        }
      ])
    end

    it "filters by cultivo_id" do
      cultivo = create(:cultivo)
      orden_match = create(:orden_fumigacion, cultivo: cultivo)
      create(:orden_fumigacion)

      get ordenes_fumigacion_url, params: { cultivo_id: cultivo.id }, headers: valid_headers

      expect(response_ids).to eq([ orden_match.id ])
    end

    it "filters by maquinista_id" do
      maquinista_match = create(:maquinista)
      orden_match = create(:orden_fumigacion, maquinista: maquinista_match)
      create(:orden_fumigacion, maquinista: create(:maquinista))

      get ordenes_fumigacion_url, params: { maquinista_id: maquinista_match.id }, headers: valid_headers

      expect(response_ids).to eq([ orden_match.id ])
    end

    it "filters by cultivo_id and maquinista_id" do
      cultivo_match = create(:cultivo)
      maquinista_match = create(:maquinista)
      orden_match = create(:orden_fumigacion, cultivo: cultivo_match, maquinista: maquinista_match)
      create(:orden_fumigacion, cultivo: cultivo_match, maquinista: create(:maquinista))
      create(:orden_fumigacion, cultivo: create(:cultivo), maquinista: maquinista_match)

      get ordenes_fumigacion_url,
          params: { cultivo_id: cultivo_match.id, maquinista_id: maquinista_match.id },
          headers: valid_headers

      expect(response_ids).to eq([ orden_match.id ])
    end

    it "filters by fecha_desde" do
      orden_match = create(:orden_fumigacion, fecha_trabajo: Date.new(2099, 1, 10))
      orden_no_match = create(:orden_fumigacion, fecha_trabajo: Date.new(2099, 1, 5))

      get ordenes_fumigacion_url, params: { fecha_desde: "2099-01-08" }, headers: valid_headers

      expect(response_ids).to include(orden_match.id)
      expect(response_ids).not_to include(orden_no_match.id)
    end

    it "filters by fecha_hasta" do
      orden_match = create(:orden_fumigacion, fecha_trabajo: Date.new(1900, 1, 5))
      orden_no_match = create(:orden_fumigacion, fecha_trabajo: Date.new(1900, 1, 10))

      get ordenes_fumigacion_url, params: { fecha_hasta: "1900-01-08" }, headers: valid_headers

      expect(response_ids).to include(orden_match.id)
      expect(response_ids).not_to include(orden_no_match.id)
    end

    it "filters by lote_id" do
      lote_match = create(:lote)
      orden_match = create(:orden_fumigacion, lotes: [ lote_match ])
      create(:orden_fumigacion, lotes: [ create(:lote) ])

      get ordenes_fumigacion_url, params: { lote_id: lote_match.id }, headers: valid_headers

      expect(response_ids).to eq([ orden_match.id ])
    end

    it "filters by estancia_id" do
      estancia_match = create(:estancia)
      lote_match = create(:lote, estancia: estancia_match)
      orden_match = create(:orden_fumigacion, lotes: [ lote_match ])
      create(:orden_fumigacion, lotes: [ create(:lote) ])

      get ordenes_fumigacion_url, params: { estancia_id: estancia_match.id }, headers: valid_headers

      expect(response_ids).to eq([ orden_match.id ])
    end

    it "filters by nro_orden_cliente with partial match" do
      orden_match = create(:orden_fumigacion)
      factura = create(:factura, ordenes_fumigacion: [])
      create(:facturas_ordenes_fumigacion, orden_fumigacion: orden_match, factura: factura, nro_orden_cliente: "CLIENTE-123")
      create(:facturas_ordenes_fumigacion, orden_fumigacion: create(:orden_fumigacion), factura: create(:factura, ordenes_fumigacion: []), nro_orden_cliente: "OTRO-999")

      get ordenes_fumigacion_url, params: { nro_orden_cliente: "ente-12" }, headers: valid_headers

      expect(response_ids).to eq([ orden_match.id ])
    end

    it "filters by nro_factura with partial match" do
      orden_match = create(:orden_fumigacion)
      create(:factura, ordenes_fumigacion: [ orden_match ], nro_factura: "FAC-001-TEST")
      create(:factura, ordenes_fumigacion: [ create(:orden_fumigacion) ], nro_factura: "FAC-999")

      get ordenes_fumigacion_url, params: { nro_factura: "001" }, headers: valid_headers

      expect(response_ids).to eq([ orden_match.id ])
    end

    it "orders results by id desc" do
      first = create(:orden_fumigacion)
      second = create(:orden_fumigacion)

      get ordenes_fumigacion_url, headers: valid_headers

      expect(response_ids.first(2)).to eq([ second.id, first.id ])
    end
  end

  describe "GET /show" do
    context "with one lote" do
      it "renders a successful response" do
        orden_fumigacion = create(:orden_fumigacion)
        get orden_fumigacion_url(orden_fumigacion), headers: valid_headers
        expect(response).to be_successful
        expect(json_response['cultivo']['id']).to eq(orden_fumigacion.cultivo_id)
        expect(json_response['cultivo']['nombre']).to eq(orden_fumigacion.cultivo.nombre)
      end

      it "includes adjuntos data when present" do
        orden_fumigacion = create(:orden_fumigacion)
        orden_fumigacion.adjuntos.attach(file_png)

        get orden_fumigacion_url(orden_fumigacion), headers: valid_headers

        expect(json_response["adjuntos"].first.keys).to match_array(%w[id filename url])
        expect(json_response["adjuntos"].first["filename"]).to eq("sample_file.png")
      end

      it "includes facturas data when present" do
        orden_fumigacion = create(:orden_fumigacion)
        fecha_factura = Date.new(2026, 1, 10)
        fecha_pago = Date.new(2026, 1, 12)
        factura = create(:factura, ordenes_fumigacion: [], fecha_factura: fecha_factura, fecha_pago: fecha_pago, nro_factura: "FAC-2026")
        create(:facturas_ordenes_fumigacion, orden_fumigacion: orden_fumigacion, factura: factura, nro_orden_cliente: "ORD-100")

        get orden_fumigacion_url(orden_fumigacion), headers: valid_headers

        expect(json_response["facturas"]).to eq([
          {
            "nro_factura" => "FAC-2026",
            "nro_orden_cliente" => "ORD-100",
            "fecha_factura" => fecha_factura.to_s,
            "fecha_pago" => fecha_pago.to_s
          }
        ])
      end
    end

    context "with many lotes" do
      it "renders a successful response" do
        orden_fumigacion = create(:orden_fumigacion, :many_lotes)
        get orden_fumigacion_url(orden_fumigacion), headers: valid_headers
        expect(response).to be_successful
        expect(json_response['cultivo']['id']).to eq(orden_fumigacion.cultivo_id)
        expect(json_response['cultivo']['nombre']).to eq(orden_fumigacion.cultivo.nombre)
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
        cultivo = Cultivo.find(valid_attributes['cultivo_id'])
        expect(json_response['cultivo']).to eq({ 'id' => cultivo.id, 'nombre' => cultivo.nombre })
        expect(json_response['sensible']).to eq(true)
        expect(json_response['comentarios']).to eq("Orden sensible")
      end

      it "asigna hectareas_reales por defecto" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: valid_attributes }, headers: valid_headers, as: :json
        lote_orden = LoteOrdenFumigacion.last
        expect(lote_orden.hectareas_reales.to_f).to eq(lote_orden.lote.hectareas.to_f)
      end

      it "respeta hectareas_reales provistas" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: valid_attributes_with_hectareas_reales }, headers: valid_headers, as: :json
        lote_orden = LoteOrdenFumigacion.last
        expect(lote_orden.hectareas_reales.to_f).to eq(10.5)
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
        cultivo = Cultivo.find(valid_attributes_many_lotes['cultivo_id'])
        expect(json_response['cultivo']).to eq({ 'id' => cultivo.id, 'nombre' => cultivo.nombre })
      end
    end

    context "with invalid parameters, no lotes" do
      it "creates a new OrdenFumigacion" do
        expect {
          post ordenes_fumigacion_url,
               params: { orden_fumigacion: invalid_attributes_no_lotes }, headers: valid_headers, as: :json
        }.to change(OrdenFumigacion, :count).by(0)
      end

      it "renders a JSON response with the new orden_fumigacion" do
        post ordenes_fumigacion_url,
             params: { orden_fumigacion: invalid_attributes_no_lotes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["base"][0]).to eq("Debe tener al menos un lote.")
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
        orden_fumigacion = create(:orden_fumigacion)
        patch orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: new_attributes }, headers: valid_headers, as: :json
        orden_fumigacion.reload
        expect(orden_fumigacion.info_trabajo).to eq("updated info")
        expect(orden_fumigacion.sensible).to eq(true)
        expect(orden_fumigacion.comentarios).to eq("Actualizado")
      end

      it "renders a JSON response with the orden_fumigacion" do
        orden_fumigacion = create(:orden_fumigacion)
        patch orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(json_response['sensible']).to eq(true)
        expect(json_response['comentarios']).to eq("Actualizado")
      end

      it "updates cultivo_id" do
        orden_fumigacion = create(:orden_fumigacion)
        new_cultivo = create(:cultivo)
        patch orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: { cultivo_id: new_cultivo.id } }, headers: valid_headers, as: :json
        orden_fumigacion.reload
        expect(orden_fumigacion.cultivo_id).to eq(new_cultivo.id)
        expect(json_response['cultivo']).to eq({ 'id' => new_cultivo.id, 'nombre' => new_cultivo.nombre })
      end

      it "attaches adjuntos on update" do
        orden_fumigacion = create(:orden_fumigacion)

        expect do
          patch orden_fumigacion_url(orden_fumigacion),
                params: { orden_fumigacion: { adjuntos: [ file_png ] } }, headers: valid_headers
        end.to change { orden_fumigacion.reload.adjuntos.count }.by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response["adjuntos"].first.keys).to match_array(%w[id filename url])
        expect(json_response["adjuntos"].first["filename"]).to eq("sample_file.png")
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the orden_fumigacion" do
        orden_fumigacion = create(:orden_fumigacion)
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
        orden_fumigacion = create(:orden_fumigacion)
        patch terminar_orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: atributos_terminada }, headers: valid_headers, as: :json
        orden_fumigacion.reload
        expect(orden_fumigacion.maquinista.nombre).to eq(maquinista.nombre)
        expect(orden_fumigacion.info_trabajo).to eq("info")
        expect(orden_fumigacion.fecha_trabajo).to eq(Date.today)
        expect(orden_fumigacion.estado_orden).to eq("terminada")
      end

      it "renders a JSON response with the orden_fumigacion" do
        orden_fumigacion = create(:orden_fumigacion)
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
        orden_fumigacion = create(:orden_fumigacion)
        patch orden_fumigacion_url(orden_fumigacion),
              params: { orden_fumigacion: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "GET /pendiente_factura" do
    it "returns agrupado por estancia" do
      estancia = create(:estancia, nombre: "Estancia 1")
      lote = create(:lote, estancia: estancia, hectareas: 22)
      orden = create(:orden_fumigacion, :terminada, lotes: [ lote ], fecha_trabajo: Date.new(2025, 10, 22))
      orden_facturada = create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2025, 10, 23))
      create(:factura, ordenes_fumigacion: [ orden_facturada ], fecha_factura: Date.current)
      create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2025, 11, 1))
      create(:orden_fumigacion, :activa, fecha_trabajo: Date.new(2025, 10, 22))

      get pendiente_factura_ordenes_fumigacion_url,
          params: { fecha_desde: "2025-10-01", fecha_hasta: "2025-10-31" },
          headers: valid_headers

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
              "fecha_trabajo_ddmmyyyy" => "22/10/2025",
              "maquinista" => orden.maquinista&.nombre,
              "orden_id" => orden.id
            }
          ]
        }
      ])
    end

    it "returns todas cuando no hay fechas" do
      estancia = create(:estancia, nombre: "Estancia 1")
      lote = create(:lote, estancia: estancia, hectareas: 22)
      lote_dos = create(:lote, estancia: estancia, hectareas: 16.99)
      orden = create(:orden_fumigacion, :terminada, lotes: [ lote ], fecha_trabajo: Date.new(2025, 10, 22))
      orden_dos = create(:orden_fumigacion, :terminada, lotes: [ lote_dos ], fecha_trabajo: Date.new(2025, 11, 1))
      create(:orden_fumigacion, :activa, fecha_trabajo: Date.new(2025, 10, 22))

      get pendiente_factura_ordenes_fumigacion_url, headers: valid_headers

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
              "fecha_trabajo_ddmmyyyy" => "22/10/2025",
              "maquinista" => orden.maquinista&.nombre,
              "orden_id" => orden.id
            },
            {
              "lote_id" => lote_dos.id,
              "hectareas" => lote_dos.hectareas.to_s,
              "fecha_trabajo" => "2025-11-01",
              "fecha_trabajo_ddmmyyyy" => "01/11/2025",
              "maquinista" => orden_dos.maquinista&.nombre,
              "orden_id" => orden_dos.id
            }
          ]
        }
      ])
    end

    it "validates required params" do
      get pendiente_factura_ordenes_fumigacion_url,
          params: { fecha_desde: "", fecha_hasta: "2025-10-31" },
          headers: valid_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("fecha_desde y fecha_hasta son requeridas")
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested orden_fumigacion" do
      orden_fumigacion = create(:orden_fumigacion)
      expect {
        delete orden_fumigacion_url(orden_fumigacion), headers: valid_headers, as: :json
      }.to change(OrdenFumigacion, :count).by(-1)
    end
  end
end
