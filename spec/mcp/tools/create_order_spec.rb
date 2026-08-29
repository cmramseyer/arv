require "rails_helper"

RSpec.describe Mcp::Tools::CreateOrder do
  it "returns a tool error when the lote belongs to another estancia" do
    estancia = create(:estancia)
    lote = create(:lote)
    producto = create(:producto)

    response = described_class.call(
      request_id: "request-123",
      estancia_id: estancia.id,
      lote_id: lote.id,
      producto_id: producto.id,
      cantidad: 20,
      server_context: { creator: create(:user) }
    )

    expect(response).to be_error
    expect(response.structured_content).to include(:error)
  end
end
