require "swagger_helper"

RSpec.describe "Cultivos API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  path "/cultivos" do
    get "Lista cultivos" do
      tags "Cultivos"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "cultivos encontrados" do
        before do
          create(:cultivo)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/Cultivo" }

        run_test!
      end
    end

    post "Crea un cultivo" do
      tags "Cultivos"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/CultivoRequest" }

      response "201", "cultivo creado" do
        let(:payload) do
          {
            cultivo: {
              nombre: "Soja"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Cultivo"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            cultivo: {
              nombre: nil
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/cultivos/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Muestra un cultivo" do
      tags "Cultivos"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "cultivo encontrado" do
        let(:id) { create(:cultivo).id }

        schema "$ref" => "#/components/schemas/Cultivo"

        run_test!
      end
    end

    patch "Actualiza un cultivo" do
      tags "Cultivos"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/CultivoRequest" }

      response "200", "cultivo actualizado" do
        let(:id) { create(:cultivo).id }
        let(:payload) do
          {
            cultivo: {
              nombre: "Maiz"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Cultivo"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:id) { create(:cultivo).id }
        let(:payload) do
          {
            cultivo: {
              nombre: nil
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end

    delete "Elimina un cultivo" do
      tags "Cultivos"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      response "204", "cultivo eliminado" do
        let(:id) { create(:cultivo).id }

        run_test!
      end
    end
  end
end
