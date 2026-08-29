require "rails_helper"

RSpec.describe Mcp::Tools::ResolveOrder do
  it "resolves normalized names and scopes the lot to the estancia" do
    estancia = create(:estancia, nombre: "San José")
    lote = create(:lote, estancia: estancia, nombre: "Norte")
    create(:lote, nombre: "Norte")
    producto = create(:producto, nombre: "Roundup", unidad_medida: :litros)

    response = described_class.call(
      estancia: " san jose ",
      lote: "norte",
      producto: "ROUNDUP",
      cantidad: 20,
      server_context: {}
    )

    expect(response.structured_content).to eq(
      valid: true,
      estancia: { status: "resolved", id: estancia.id, nombre: "San José" },
      lote: { status: "resolved", id: lote.id, nombre: "Norte" },
      producto: { status: "resolved", id: producto.id, nombre: "Roundup", unidad_medida: "litros" },
      cantidad: 20
    )
  end

  it "returns close matches as suggestions without resolving them" do
    create(:estancia, nombre: "Pepitos")
    producto = create(:producto, nombre: "Roundup")

    response = described_class.call(
      estancia: "Pepito",
      lote: "Norte",
      producto: producto.nombre,
      cantidad: 20,
      server_context: {}
    )

    expect(response.structured_content).to include(
      valid: false,
      estancia: {
        status: "not_found",
        matches: [ { id: Estancia.find_by!(nombre: "Pepitos").id, nombre: "Pepitos" } ]
      },
      lote: { status: "not_searched", reason: "estancia_not_resolved", matches: [] }
    )
  end

  it "returns ambiguous when normalized estancia names are duplicated" do
    create(:estancia, nombre: "San José")
    create(:estancia, nombre: "San Jose")
    producto = create(:producto, nombre: "Roundup")

    response = described_class.call(
      estancia: "San Jose",
      lote: "Norte",
      producto: producto.nombre,
      cantidad: 20,
      server_context: {}
    )

    expect(response.structured_content.dig(:estancia, :status)).to eq("ambiguous")
    expect(response.structured_content).to include(valid: false)
  end
end
