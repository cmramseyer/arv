require "rails_helper"

RSpec.describe Mcp::Tools::SearchLotes do
  it "only returns lots from the requested estancia" do
    estancia = create(:estancia)
    lote = create(:lote, estancia: estancia, nombre: "Norte")
    create(:lote, nombre: "Norte")

    response = described_class.call(estancia_id: estancia.id, query: "norte", server_context: {})

    expect(response.structured_content).to eq(lotes: [ { id: lote.id, nombre: "Norte" } ])
  end
end
