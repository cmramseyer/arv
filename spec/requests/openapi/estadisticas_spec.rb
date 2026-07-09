require "swagger_helper"

RSpec.describe "Estadisticas API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  let(:Authorization) { authenticated_header(user)["Authorization"] }

  path "/estadisticas" do
    get "Obtiene estadisticas agregadas" do
      tags "Estadisticas"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :fecha_desde,
                in: :query,
                required: true,
                schema: { type: :string, format: :date }
      parameter name: :fecha_hasta,
                in: :query,
                required: true,
                schema: { type: :string, format: :date }

      response "200", "estadisticas encontradas" do
        let(:fecha_desde) { "2026-01-10" }
        let(:fecha_hasta) { "2026-01-10" }

        before do
          fecha = Date.new(2026, 1, 10)
          estancia = create(:estancia, nombre: "Estancia 1")
          lote = create(:lote, estancia: estancia, hectareas: 20.5)
          maquinista = create(:maquinista, nombre: "Juan")
          cultivo = create(:cultivo, nombre: "Soja")
          orden = create(
            :orden_fumigacion,
            :terminada,
            fecha_trabajo: fecha,
            lotes: [ lote ],
            maquinista: maquinista,
            cultivo: cultivo
          )

          create(:factura, ordenes_fumigacion: [ orden ], fecha_factura: fecha, fecha_pago: fecha)
        end

        schema "$ref" => "#/components/schemas/Estadistica"

        run_test!
      end

      response "422", "fechas requeridas" do
        let(:fecha_desde) { "" }
        let(:fecha_hasta) { "2026-01-10" }

        schema "$ref" => "#/components/schemas/ErrorMessage"

        run_test!
      end

      response "422", "fechas invalidas" do
        let(:fecha_desde) { "fecha-invalida" }
        let(:fecha_hasta) { "2026-01-10" }

        schema "$ref" => "#/components/schemas/ErrorMessage"

        run_test!
      end
    end
  end
end
