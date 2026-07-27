require "swagger_helper"

RSpec.describe "Maquinistas API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  let(:Authorization) { authenticated_header(user)["Authorization"] }

  path "/maquinistas" do
    get "Lista maquinistas" do
      tags "Maquinistas"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "maquinistas encontrados" do
        before do
          create(:maquinista)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/Maquinista" }

        run_test!
      end
    end

    post "Crea un maquinista" do
      tags "Maquinistas"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/MaquinistaRequest" }

      response "201", "maquinista creado" do
        let(:payload) do
          {
            maquinista: {
              nombre: "Juan"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Maquinista"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            maquinista: {
              nombre: nil
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/maquinistas/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Muestra un maquinista" do
      tags "Maquinistas"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "maquinista encontrado" do
        let(:id) { create(:maquinista).id }

        schema "$ref" => "#/components/schemas/Maquinista"

        run_test!
      end
    end

    patch "Actualiza un maquinista" do
      tags "Maquinistas"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/MaquinistaRequest" }

      response "200", "maquinista actualizado" do
        let(:id) { create(:maquinista).id }
        let(:payload) do
          {
            maquinista: {
              nombre: "Pedro"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Maquinista"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:id) { create(:maquinista).id }
        let(:payload) do
          {
            maquinista: {
              nombre: nil
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end

    delete "Elimina un maquinista" do
      tags "Maquinistas"
      security [ bearerAuth: [] ]

      response "204", "maquinista eliminado" do
        let(:id) { create(:maquinista).id }

        run_test!
      end
    end
  end
end
