require "rails_helper"

RSpec.describe Mcp::Tools::ListOrdenesActivas do
  it "returns active orders with their estancia, lots, and creation date" do
    estancia = create(:estancia, nombre: "Estancia Norte")
    lote = create(:lote, estancia: estancia, nombre: "Lote 7")
    orden = create(:orden_fumigacion, :activa, estancia: estancia, lotes: [ lote ])
    create(:orden_fumigacion, :terminada)

    response = described_class.call(server_context: {})

    expect(response.structured_content).to eq(
      cantidad: 1,
      ordenes: [
        {
          nro_orden: orden.id,
          estancia: { id: estancia.id, nombre: "Estancia Norte" },
          lotes: [ { id: lote.id, nombre: "Lote 7" } ],
          fecha_creacion: orden.created_at.iso8601
        }
      ]
    )
  end
end
