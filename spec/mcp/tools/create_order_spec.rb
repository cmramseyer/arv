require "rails_helper"

RSpec.describe Mcp::Tools::CreateOrder do
  let(:creator) { create(:user) }
  let(:estancia) { create(:estancia, nombre: "San Jose") }
  let(:lote) { create(:lote, estancia: estancia, nombre: "Norte") }
  let(:producto) { create(:producto, nombre: "Roundup") }

  it "resolves business names and creates an order with an optional crop" do
    cultivo = create(:cultivo, nombre: "Soja")

    response = described_class.call(
      request_id: "request-123",
      estancia: estancia.nombre,
      lote: lote.nombre,
      producto: producto.nombre,
      cultivo: cultivo.nombre,
      cantidad: 20,
      server_context: { creator: creator }
    )

    expect(response).not_to be_error
    expect(response.structured_content).to include(status: "created")
    expect(OrdenFumigacion.find(response.structured_content[:order_id])).to have_attributes(
      estancia: estancia,
      cultivo: cultivo,
      creator: creator
    )
  end

  it "creates an order without a crop" do
    response = described_class.call(
      request_id: "request-123",
      estancia: estancia.nombre,
      lote: lote.nombre,
      producto: producto.nombre,
      cantidad: 20,
      server_context: { creator: creator }
    )

    order = OrdenFumigacion.find(response.structured_content[:order_id])
    expect(order.cultivo).to be_nil
  end

  it "does not create an order when a supplied crop is ambiguous" do
    create(:cultivo, nombre: "Soja")
    create(:cultivo, nombre: "SOJA")

    response = described_class.call(
      request_id: "request-123",
      estancia: estancia.nombre,
      lote: lote.nombre,
      producto: producto.nombre,
      cultivo: "soja",
      cantidad: 20,
      server_context: { creator: creator }
    )

    expect(response).not_to be_error
    expect(response.structured_content.dig(:resolution, :cultivo, :status)).to eq("ambiguous")
    expect(OrdenFumigacion).not_to exist(source_request_id: "request-123")
  end
end
