require "swagger_helper"

RSpec.describe "Estancias API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  let(:Authorization) { authenticated_header(user)["Authorization"] }

  path "/estancias" do
    get "Lista estancias" do
      tags "Estancias"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "estancias encontradas" do
        before do
          create(:estancia)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/Estancia" }

        run_test!
      end
    end

    post "Crea una estancia" do
      tags "Estancias"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/EstanciaRequest" }

      response "201", "estancia creada" do
        let(:payload) do
          {
            estancia: {
              nombre: "Estancia 1",
              contacto: "Juan Perez",
              telefono: "123456789",
              email: "juan@example.com"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Estancia"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            estancia: {
              nombre: ""
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/estancias/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Muestra una estancia" do
      tags "Estancias"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "estancia encontrada" do
        let(:id) { create(:estancia).id }

        schema "$ref" => "#/components/schemas/Estancia"

        run_test!
      end
    end

    patch "Actualiza una estancia" do
      tags "Estancias"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/EstanciaRequest" }

      response "200", "estancia actualizada" do
        let(:id) { create(:estancia).id }
        let(:payload) do
          {
            estancia: {
              nombre: "Estancia actualizada",
              contacto: "Pedro Gomez",
              telefono: "987654321",
              email: "pedro@example.com"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Estancia"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:id) { create(:estancia).id }
        let(:payload) do
          {
            estancia: {
              nombre: ""
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end

    delete "Elimina una estancia" do
      tags "Estancias"
      security [ bearerAuth: [] ]

      response "204", "estancia eliminada" do
        let(:id) { create(:estancia).id }

        run_test!
      end
    end
  end
end
