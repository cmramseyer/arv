require "swagger_helper"

RSpec.describe "Adjuntos API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }
  let(:file_png) { fixture_file_upload("sample_file.png", "image/png") }

  before { sign_in user }

  path "/adjuntos" do
    get "Lista adjuntos de una orden" do
      tags "Adjuntos"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      parameter name: :orden_fumigacion_id,
                in: :query,
                required: false,
                schema: { type: :integer }

      response "200", "adjuntos encontrados" do
        let(:lote) { create(:lote) }
        let(:orden) { create(:orden_fumigacion, lotes: [ lote ]) }
        let(:orden_fumigacion_id) { orden.id }

        before do
          lote.adjuntos.attach(file_png)
          orden.adjuntos.attach(file_png)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/Adjunto" }

        run_test!
      end

      response "422", "orden_fumigacion_id requerido" do
        let(:orden_fumigacion_id) { nil }

        schema "$ref" => "#/components/schemas/ErrorMessage"

        run_test!
      end
    end
  end

  path "/lotes/{lote_id}/adjuntos" do
    parameter name: :lote_id, in: :path, type: :integer

    post "Crea un adjunto para un lote" do
      tags "Adjuntos"
      consumes "multipart/form-data"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :adjunto,
                in: :formData,
                required: true,
                schema: { type: :string, format: :binary }

      response "201", "adjunto creado" do
        let(:"Content-Type") { "multipart/form-data" }
        let(:lote_id) { create(:lote).id }
        let(:adjunto) { file_png }

        schema "$ref" => "#/components/schemas/Adjunto"

        run_test!
      end

      response "404", "lote no encontrado" do
        let(:"Content-Type") { "multipart/form-data" }
        let(:lote_id) { 99_999 }
        let(:adjunto) { file_png }

        run_test!
      end
    end
  end

  path "/lotes/{lote_id}/adjuntos/{id}" do
    parameter name: :lote_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer

    delete "Elimina un adjunto de un lote" do
      tags "Adjuntos"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      response "204", "adjunto eliminado" do
        let(:lote) { create(:lote) }
        let(:lote_id) { lote.id }
        let(:id) do
          lote.adjuntos.attach(file_png)
          lote.adjuntos.first.id
        end

        run_test!
      end

      response "404", "lote no encontrado" do
        let(:lote) { create(:lote) }
        let(:lote_id) { 99_999 }
        let(:id) do
          lote.adjuntos.attach(file_png)
          lote.adjuntos.first.id
        end

        run_test!
      end

      response "404", "adjunto no encontrado" do
        let(:lote_id) { create(:lote).id }
        let(:id) { 99_999 }

        schema "$ref" => "#/components/schemas/ErrorMessage"

        run_test!
      end
    end
  end
end
