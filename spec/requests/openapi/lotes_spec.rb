require "swagger_helper"

RSpec.describe "Lotes API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  path "/lotes" do
    get "Lista lotes" do
      tags "Lotes"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      parameter name: :estancia_id,
                in: :query,
                required: false,
                schema: { type: :integer }

      response "200", "lotes encontrados" do
        let(:estancia_id) { nil }

        before do
          create(:lote)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/LoteFull" }

        run_test!
      end

      response "200", "lotes filtrados por estancia" do
        let(:estancia) { create(:estancia) }
        let(:estancia_id) { estancia.id }

        before do
          create(:lote, estancia: estancia)
          create(:lote)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/LoteFull" }

        run_test!
      end
    end

    post "Crea un lote" do
      tags "Lotes"
      consumes "application/json", "multipart/form-data"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/LoteRequest" }
      parameter name: :lote,
                in: :formData,
                required: false

      response "201", "lote creado" do
        let(:payload) do
          {
            lote: {
              nombre: "Lote 1",
              estancia_id: create(:estancia).id,
              hectareas: "20.5"
            }
          }
        end

        schema "$ref" => "#/components/schemas/LoteFull"

        run_test!
      end

      response "201", "lote creado con adjuntos" do
        let(:"Content-Type") { "multipart/form-data" }
        let(:file_png) { fixture_file_upload("sample_file.png", "image/png") }
        let(:lote) do
          {
            nombre: "Lote con adjunto",
            estancia_id: create(:estancia).id,
            hectareas: "20.5",
            adjuntos: [ file_png ]
          }
        end

        schema "$ref" => "#/components/schemas/LoteFull"

        run_test! do |response|
          expect(JSON.parse(response.body)["adjuntos"]).not_to be_empty
        end
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            lote: {
              nombre: nil
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/lotes/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Muestra un lote" do
      tags "Lotes"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "lote encontrado" do
        let(:id) { create(:lote).id }

        schema "$ref" => "#/components/schemas/LoteFull"

        run_test!
      end
    end

    patch "Actualiza un lote" do
      tags "Lotes"
      consumes "application/json", "multipart/form-data"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/LoteRequest" }
      parameter name: :lote,
                in: :formData,
                required: false

      response "200", "lote actualizado" do
        let(:id) { create(:lote).id }
        let(:payload) do
          {
            lote: {
              nombre: "Lote actualizado",
              estancia_id: create(:estancia).id,
              hectareas: "25.75"
            }
          }
        end

        schema "$ref" => "#/components/schemas/LoteFull"

        run_test!
      end

      response "200", "lote actualizado con adjuntos" do
        let(:"Content-Type") { "multipart/form-data" }
        let(:file_png) { fixture_file_upload("sample_file.png", "image/png") }
        let(:id) { create(:lote).id }
        let(:lote) do
          {
            nombre: "Lote actualizado con adjunto",
            adjuntos: [ file_png ]
          }
        end

        schema "$ref" => "#/components/schemas/LoteFull"

        run_test! do |response|
          expect(JSON.parse(response.body)["adjuntos"]).not_to be_empty
        end
      end

      response "422", "parametros invalidos" do
        let(:id) { create(:lote).id }
        let(:payload) do
          {
            lote: {
              nombre: nil
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end

    delete "Elimina un lote" do
      tags "Lotes"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      response "204", "lote eliminado" do
        let(:id) { create(:lote).id }

        run_test!
      end
    end
  end

  path "/lotes/{id}/adjuntos" do
    parameter name: :id, in: :path, type: :integer

    get "Lista adjuntos de un lote" do
      tags "Lotes"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "adjuntos encontrados" do
        let(:file_png) { fixture_file_upload("sample_file.png", "image/png") }
        let(:lote) { create(:lote) }
        let(:id) { lote.id }

        before do
          lote.adjuntos.attach(file_png)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/LoteAdjunto" }

        run_test!
      end
    end
  end
end
