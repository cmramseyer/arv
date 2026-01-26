require "rails_helper"

RSpec.describe "/estadisticas", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { authenticated_header(user) }

  describe "GET /index" do
    it "returns aggregated statistics for the range" do
      fecha = Date.new(2026, 1, 10)
      fecha_hora = Date.new(2026, 1, 10)

      estancia_uno = create(:estancia, nombre: "Estancia 1")
      estancia_dos = create(:estancia, nombre: "Estancia 2")
      lote_uno = create(:lote, estancia: estancia_uno, hectareas: 20.5)
      lote_dos = create(:lote, estancia: estancia_dos, hectareas: 10.25)
      maquinista = create(:maquinista, nombre: "Juan")
      cultivo = create(:cultivo, nombre: "Soja")

      orden_uno = create(
        :orden_fumigacion,
        :terminada,
        fecha_trabajo: fecha,
        lotes: [ lote_uno ],
        maquinista: maquinista,
        cultivo: cultivo
      )
      orden_dos = create(
        :orden_fumigacion,
        :terminada,
        fecha_trabajo: fecha,
        lotes: [ lote_dos ],
        maquinista: nil,
        cultivo: nil
      )

      create(:factura, ordenes_fumigacion: [ orden_uno ], fecha_factura: fecha_hora, fecha_pago: fecha_hora)
      create(:factura, ordenes_fumigacion: [ orden_dos ], fecha_factura: fecha_hora, fecha_pago: fecha_hora)

      get estadisticas_url,
          params: { fecha_desde: fecha.to_s, fecha_hasta: fecha.to_s },
          headers: valid_headers

      expect(response).to have_http_status(:ok)

      propietarios = json_response["hectareas_por_propietario"]
      maquinistas = json_response["hectareas_por_maquinista"]
      cultivos = json_response["hectareas_por_cultivo"]

      expect(propietarios.map { |item| item["nombre_estancia"] }).to eq([ "Estancia 1", "Estancia 2" ])
      expect(propietarios.map { |item| item["hectareas"].to_f }).to eq([ 20.5, 10.25 ])

      expect(maquinistas.map { |item| item["maquinista"] }).to eq([ "Juan", "Sin clasificar" ])
      expect(maquinistas.map { |item| item["hectareas"].to_f }).to eq([ 20.5, 10.25 ])

      expect(cultivos.map { |item| item["cultivo"] }).to eq([ "Soja", "Sin clasificar" ])
      expect(cultivos.map { |item| item["hectareas"].to_f }).to eq([ 20.5, 10.25 ])
    end

    it "returns empty arrays when no ordenes match" do
      fecha = Date.new(2026, 1, 10)
      fecha_hora = Date.new(2026, 1, 10)
      estancia = create(:estancia, nombre: "Estancia 1")
      lote = create(:lote, estancia: estancia, hectareas: 20.5)
      orden = create(:orden_fumigacion, :terminada, fecha_trabajo: fecha, lotes: [ lote ])

      create(:factura, ordenes_fumigacion: [ orden ], fecha_factura: fecha_hora, fecha_pago: fecha_hora)

      get estadisticas_url,
          params: { fecha_desde: "2026-01-11", fecha_hasta: "2026-01-12" },
          headers: valid_headers

      expect(response).to have_http_status(:ok)
      expect(json_response).to eq(
        "hectareas_por_propietario" => [],
        "hectareas_por_maquinista" => [],
        "hectareas_por_cultivo" => []
      )
    end
  end
end
