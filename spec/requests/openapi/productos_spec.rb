require "swagger_helper"

RSpec.describe "Productos API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  path "/productos" do
    get "Lista productos" do
      tags "Productos"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "productos encontrados" do
        before do
          create(:producto)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/Producto" }

        run_test!
      end
    end

    post "Crea un producto" do
      tags "Productos"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/ProductoRequest" }

      response "201", "producto creado" do
        let(:payload) do
          {
            producto: {
              nombre: "Herbicida",
              tipo_producto: "Quimico",
              unidad_medida: "kg"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Producto"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            producto: {
              nombre: "",
              tipo_producto: "",
              unidad_medida: "kg"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/productos/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Muestra un producto" do
      tags "Productos"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "producto encontrado" do
        let(:id) { create(:producto).id }

        schema "$ref" => "#/components/schemas/Producto"

        run_test!
      end
    end

    patch "Actualiza un producto" do
      tags "Productos"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/ProductoRequest" }

      response "200", "producto actualizado" do
        let(:id) { create(:producto).id }
        let(:payload) do
          {
            producto: {
              nombre: "Producto actualizado",
              tipo_producto: "Quimico",
              unidad_medida: "litros"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Producto"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:id) { create(:producto).id }
        let(:payload) do
          {
            producto: {
              nombre: "",
              tipo_producto: "",
              unidad_medida: "kg"
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end

    delete "Elimina un producto" do
      tags "Productos"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      response "204", "producto eliminado" do
        let(:id) { create(:producto).id }

        run_test!
      end
    end
  end
end
