require "swagger_helper"

RSpec.describe "Ordenes Fumigacion API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  path "/ordenes_fumigacion" do
    get "Lista ordenes de fumigacion" do
      tags "Ordenes Fumigacion"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      parameter name: :estado,
                in: :query,
                required: false,
                schema: { type: :string, enum: %w[activa terminada] }
      parameter name: :cultivo_id,
                in: :query,
                required: false,
                schema: { type: :integer }
      parameter name: :maquinista_id,
                in: :query,
                required: false,
                schema: { type: :integer }
      parameter name: :fecha_desde,
                in: :query,
                required: false,
                schema: { type: :string, format: :date }
      parameter name: :fecha_hasta,
                in: :query,
                required: false,
                schema: { type: :string, format: :date }
      parameter name: :lote_id,
                in: :query,
                required: false,
                schema: { type: :integer }
      parameter name: :estancia_id,
                in: :query,
                required: false,
                schema: { type: :integer }
      parameter name: :nro_orden_cliente,
                in: :query,
                required: false,
                schema: { type: :string }
      parameter name: :nro_factura,
                in: :query,
                required: false,
                schema: { type: :string }

      response "200", "ordenes encontradas" do
        let(:estado) { nil }
        let(:cultivo_id) { nil }
        let(:maquinista_id) { nil }
        let(:fecha_desde) { nil }
        let(:fecha_hasta) { nil }
        let(:lote_id) { nil }
        let(:estancia_id) { nil }
        let(:nro_orden_cliente) { nil }
        let(:nro_factura) { nil }

        before do
          create(:orden_fumigacion)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/OrdenFumigacion" }

        run_test!
      end

      response "200", "ordenes filtradas por cultivo" do
        let(:cultivo) { create(:cultivo) }
        let(:estado) { nil }
        let(:cultivo_id) { cultivo.id }
        let(:maquinista_id) { nil }
        let(:fecha_desde) { nil }
        let(:fecha_hasta) { nil }
        let(:lote_id) { nil }
        let(:estancia_id) { nil }
        let(:nro_orden_cliente) { nil }
        let(:nro_factura) { nil }

        before do
          create(:orden_fumigacion, cultivo: cultivo)
          create(:orden_fumigacion)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/OrdenFumigacion" }

        run_test!
      end
    end

    post "Crea una orden de fumigacion" do
      tags "Ordenes Fumigacion"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/OrdenFumigacionRequest" }

      response "201", "orden creada" do
        let(:payload) do
          lote = create(:lote)

          {
            orden_fumigacion: {
              estancia_id: lote.estancia_id,
              cultivo_id: create(:cultivo).id,
              sensible: true,
              comentarios: "Orden sensible",
              lotes: [
                {
                  lote_id: lote.id,
                  dosis: [
                    {
                      producto_id: create(:producto).id,
                      cantidad: 10
                    }
                  ]
                }
              ]
            }
          }
        end

        schema "$ref" => "#/components/schemas/OrdenFumigacion"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            orden_fumigacion: {
              cultivo_id: create(:cultivo).id,
              sensible: true,
              comentarios: "Orden sin lotes",
              lotes: []
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/ordenes_fumigacion/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Muestra una orden de fumigacion" do
      tags "Ordenes Fumigacion"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "orden encontrada" do
        let(:id) { create(:orden_fumigacion).id }

        schema "$ref" => "#/components/schemas/OrdenFumigacion"

        run_test!
      end
    end

    patch "Actualiza una orden de fumigacion" do
      tags "Ordenes Fumigacion"
      consumes "application/json", "multipart/form-data"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/OrdenFumigacionRequest" }
      parameter name: :orden_fumigacion,
                in: :formData,
                required: false

      response "200", "orden actualizada" do
        let(:id) { create(:orden_fumigacion).id }
        let(:payload) do
          {
            orden_fumigacion: {
              info_trabajo: "Trabajo actualizado",
              sensible: true,
              comentarios: "Comentarios actualizados",
              cultivo_id: create(:cultivo).id
            }
          }
        end

        schema "$ref" => "#/components/schemas/OrdenFumigacion"

        run_test!
      end

      response "200", "orden actualizada con adjuntos" do
        let(:"Content-Type") { "multipart/form-data" }
        let(:file_png) { fixture_file_upload("sample_file.png", "image/png") }
        let(:id) { create(:orden_fumigacion).id }
        let(:orden_fumigacion) do
          {
            adjuntos: [ file_png ]
          }
        end

        schema "$ref" => "#/components/schemas/OrdenFumigacion"

        run_test! do |response|
          expect(JSON.parse(response.body)["adjuntos"]).not_to be_empty
        end
      end

      response "422", "parametros invalidos" do
        let(:id) { create(:orden_fumigacion).id }
        let(:payload) do
          {
            orden_fumigacion: {
              creator_id: nil
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end

    delete "Elimina una orden de fumigacion" do
      tags "Ordenes Fumigacion"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      response "204", "orden eliminada" do
        let(:id) { create(:orden_fumigacion).id }

        run_test!
      end
    end
  end

  path "/ordenes_fumigacion/{id}/pdf" do
    parameter name: :id, in: :path, type: :integer

    get "Genera PDF de una orden de fumigacion" do
      tags "Ordenes Fumigacion"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      parameter name: :attachment_ids,
                in: :query,
                required: false,
                schema: { type: :array, items: { type: :integer } }

      response "200", "pdf generado" do
        let(:id) { create(:orden_fumigacion).id }
        let(:attachment_ids) { nil }

        schema "$ref" => "#/components/schemas/OrdenPdfResponse"

        run_test!
      end
    end
  end

  path "/ordenes_fumigacion/pendiente_factura" do
    get "Lista ordenes pendientes de factura" do
      tags "Ordenes Fumigacion"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      parameter name: :fecha_desde,
                in: :query,
                required: false,
                schema: { type: :string, format: :date }
      parameter name: :fecha_hasta,
                in: :query,
                required: false,
                schema: { type: :string, format: :date }

      response "200", "ordenes pendientes encontradas" do
        let(:fecha_desde) { "2025-10-01" }
        let(:fecha_hasta) { "2025-10-31" }

        before do
          estancia = create(:estancia, nombre: "Estancia 1")
          lote = create(:lote, estancia: estancia, hectareas: 22)
          create(:orden_fumigacion, :terminada, lotes: [ lote ], fecha_trabajo: Date.new(2025, 10, 22))
          create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2025, 11, 1))
          create(:orden_fumigacion, :activa, fecha_trabajo: Date.new(2025, 10, 22))
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/PendienteFacturaEstancia" }

        run_test!
      end

      response "422", "fecha incompleta" do
        let(:fecha_desde) { "" }
        let(:fecha_hasta) { "2025-10-31" }

        schema "$ref" => "#/components/schemas/ErrorMessage"

        run_test!
      end
    end
  end

  path "/ordenes_fumigacion/{id}/terminar" do
    parameter name: :id, in: :path, type: :integer

    patch "Termina una orden de fumigacion" do
      tags "Ordenes Fumigacion"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/TerminarOrdenFumigacionRequest" }

      response "200", "orden terminada" do
        let(:maquinista) { create(:maquinista) }
        let(:id) { create(:orden_fumigacion).id }
        let(:payload) do
          {
            orden_fumigacion: {
              info_trabajo: "Trabajo finalizado",
              maquinista_id: maquinista.id,
              fecha_trabajo: "2026-01-20"
            }
          }
        end

        schema "$ref" => "#/components/schemas/OrdenFumigacion"

        run_test!
      end

      response "422", "orden ya terminada" do
        let(:maquinista) { create(:maquinista) }
        let(:id) { create(:orden_fumigacion, :terminada).id }
        let(:payload) do
          {
            orden_fumigacion: {
              info_trabajo: "Trabajo finalizado",
              maquinista_id: maquinista.id,
              fecha_trabajo: "2026-01-20"
            }
          }
        end

        schema "$ref" => "#/components/schemas/ErrorMessage"

        run_test!
      end
    end
  end
end
