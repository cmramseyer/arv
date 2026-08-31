require "rails_helper"

RSpec.describe "MCP catalog tools" do
  it "lists all estancias in name order" do
    create(:estancia, nombre: "Zarate")
    estancia = create(:estancia, nombre: "Alamos")

    response = Mcp::Tools::ListEstancias.call(server_context: {})

    expect(response.structured_content[:estancias].first).to eq(id: estancia.id, nombre: "Alamos")
  end

  it "lists all products with their units" do
    producto = create(:producto, nombre: "Atrazina", unidad_medida: :litros)

    response = Mcp::Tools::ListProductos.call(server_context: {})

    expect(response.structured_content[:productos]).to include(
      id: producto.id,
      nombre: "Atrazina",
      unidad_medida: "litros"
    )
  end

  it "lists and searches crops" do
    cultivo = create(:cultivo, nombre: "Soja")

    list_response = Mcp::Tools::ListCultivos.call(server_context: {})
    search_response = Mcp::Tools::SearchCultivos.call(query: "soj", server_context: {})

    expected = { id: cultivo.id, nombre: "Soja" }
    expect(list_response.structured_content[:cultivos]).to include(expected)
    expect(search_response.structured_content[:cultivos]).to include(expected)
  end
end
