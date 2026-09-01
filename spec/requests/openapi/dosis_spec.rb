require "swagger_helper"

RSpec.describe "Dosis API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  def dosis_attributes
    orden = create(:orden_fumigacion)
    lote_orden = orden.lote_ordenes_fumigacion.first

    {
      cantidad: 10,
      producto_id: create(:producto).id,
      lote_orden_fumigacion_id: lote_orden.id
    }
  end

  path "/dosis" do
    get "Lista dosis" do
      tags "Dosis"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "dosis encontradas" do
        before do
          Dosis.create!(dosis_attributes)
        end

        schema type: :array,
               items: { "$ref" => "#/components/schemas/Dosis" }

        run_test!
      end
    end

    post "Crea una dosis" do
      tags "Dosis"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/DosisRequest" }

      response "201", "dosis creada" do
        let(:payload) do
          {
            dosis: dosis_attributes
          }
        end

        schema "$ref" => "#/components/schemas/Dosis"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:payload) do
          {
            dosis: {
              cantidad: 0
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end
  end

  path "/dosis/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Muestra una dosis" do
      tags "Dosis"
      produces "application/json"
      security [ sessionCookieAuth: [] ]

      response "200", "dosis encontrada" do
        let(:id) { Dosis.create!(dosis_attributes).id }

        schema "$ref" => "#/components/schemas/Dosis"

        run_test!
      end
    end

    patch "Actualiza una dosis" do
      tags "Dosis"
      consumes "application/json"
      produces "application/json"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/DosisRequest" }

      response "200", "dosis actualizada" do
        let(:id) { Dosis.create!(dosis_attributes).id }
        let(:payload) do
          {
            dosis: {
              cantidad: 1,
              producto_id: create(:producto).id,
              lote_orden_fumigacion_id: create(:orden_fumigacion).lote_ordenes_fumigacion.first.id
            }
          }
        end

        schema "$ref" => "#/components/schemas/Dosis"

        run_test!
      end

      response "422", "parametros invalidos" do
        let(:id) { Dosis.create!(dosis_attributes).id }
        let(:payload) do
          {
            dosis: {
              cantidad: 0
            }
          }
        end

        schema "$ref" => "#/components/schemas/Error"

        run_test!
      end
    end

    delete "Elimina una dosis" do
      tags "Dosis"
      security [ sessionCookieAuth: [], csrfTokenAuth: [] ]

      response "204", "dosis eliminada" do
        let(:id) { Dosis.create!(dosis_attributes).id }

        run_test!
      end
    end
  end
end
