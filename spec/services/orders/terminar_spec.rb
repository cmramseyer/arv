require "rails_helper"

RSpec.describe Orders::Terminar do
  let(:maquinista) { create(:maquinista) }
  let(:orden) { create(:orden_fumigacion, :activa) }
  let(:attributes) do
    {
      maquinista_id: maquinista.id,
      fecha_trabajo: Date.new(2026, 8, 29)
    }
  end

  it "terminates an active order with the supplied work details" do
    result = described_class.call(nro_orden: orden.id, attributes: attributes)

    expect(result.status).to eq("terminated")
    expect(result.orden).to have_attributes(
      estado_orden: "terminada",
      maquinista: maquinista,
      fecha_trabajo: Date.new(2026, 8, 29)
    )
  end

  it "does not modify an order that was already terminated" do
    orden.update!(estado_orden: "terminada", maquinista: maquinista, fecha_trabajo: Date.new(2026, 8, 28))

    result = described_class.call(nro_orden: orden.id, attributes: attributes)

    expect(result.status).to eq("already_terminated")
    expect(result.orden).to have_attributes(fecha_trabajo: Date.new(2026, 8, 28))
  end

  it "raises when the order does not exist" do
    expect do
      described_class.call(nro_orden: 99_999, attributes: attributes)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
