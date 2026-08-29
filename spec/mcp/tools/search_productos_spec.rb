require "rails_helper"

RSpec.describe Mcp::Tools::SearchProductos do
  it "returns matching products with their units" do
    producto = create(:producto, nombre: "Roundup", unidad_medida: :litros)
    create(:producto, nombre: "Atrazina")

    response = described_class.call(query: "round", server_context: {})

    expect(response.structured_content).to eq(
      productos: [ { id: producto.id, nombre: "Roundup", unidad_medida: "litros" } ]
    )
  end
end
