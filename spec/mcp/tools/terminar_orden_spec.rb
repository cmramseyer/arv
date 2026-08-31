require "rails_helper"

RSpec.describe Mcp::Tools::TerminarOrden do
  let(:orden) { create(:orden_fumigacion, :activa) }
  let(:maquinista) { create(:maquinista, nombre: "Juan Perez") }
  let(:server_context) { { creator: create(:user) } }

  before { maquinista }

  it "terminates an order using a resolved maquinista and ISO date" do
    response = described_class.call(
      nro_orden: orden.id,
      maquinista: "juan pérez",
      fecha: "2026-08-29",
      server_context: server_context
    )

    expect(response).not_to be_error
    expect(response.structured_content).to include(order_id: orden.id, status: "terminated")
    expect(orden.reload).to have_attributes(
      estado_orden: "terminada",
      maquinista: maquinista,
      fecha_trabajo: Date.new(2026, 8, 29)
    )
  end

  it "returns the existing terminal status without modifying the order" do
    orden.update!(estado_orden: "terminada", maquinista: maquinista, fecha_trabajo: Date.new(2026, 8, 28))

    response = described_class.call(
      nro_orden: orden.id,
      maquinista: maquinista.nombre,
      fecha: "2026-08-29",
      server_context: server_context
    )

    expect(response).not_to be_error
    expect(response.structured_content).to include(status: "already_terminated")
    expect(orden.reload.fecha_trabajo).to eq(Date.new(2026, 8, 28))
  end

  it "asks for clarification when the maquinista is ambiguous" do
    create(:maquinista, nombre: "JUAN PEREZ")

    response = described_class.call(
      nro_orden: orden.id,
      maquinista: maquinista.nombre,
      fecha: "2026-08-29",
      server_context: server_context
    )

    expect(response).not_to be_error
    expect(response.structured_content.dig(:maquinista, :status)).to eq("ambiguous")
    expect(orden.reload).to be_activa
  end

  it "returns an error for a date outside the ISO format" do
    response = described_class.call(
      nro_orden: orden.id,
      maquinista: maquinista.nombre,
      fecha: "29/08/2026",
      server_context: server_context
    )

    expect(response).to be_error
    expect(response.structured_content.fetch(:error)).to include("invalid date")
    expect(orden.reload).to be_activa
  end

  it "returns an error when the order does not exist" do
    response = described_class.call(
      nro_orden: 99_999,
      maquinista: maquinista.nombre,
      fecha: "2026-08-29",
      server_context: server_context
    )

    expect(response).to be_error
    expect(response.structured_content.fetch(:error)).to include("Couldn't find OrdenFumigacion")
  end
end
