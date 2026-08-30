require "rails_helper"

RSpec.describe Orders::Create do
  let(:creator) { create(:user) }
  let(:estancia) { create(:estancia) }
  let(:lote) { create(:lote, estancia: estancia) }
  let(:producto) { create(:producto) }
  let(:attributes) do
    {
      request_id: "request-123",
      estancia_id: estancia.id,
      lote_id: lote.id,
      producto_id: producto.id,
      cantidad: 20,
      creator: creator
    }
  end

  it "creates one order with one lote and one dose" do
    orden = described_class.call(**attributes)

    expect(orden).to have_attributes(estancia: estancia, creator: creator, source_request_id: "request-123")
    expect(orden.lote_ordenes_fumigacion.size).to eq(1)
    expect(orden.lote_ordenes_fumigacion.first).to have_attributes(lote: lote)
    expect(orden.lote_ordenes_fumigacion.first.dosis).to contain_exactly(
      have_attributes(producto: producto, cantidad: 20)
    )
  end

  it "returns the existing order for the same request id" do
    first_order = described_class.call(**attributes)

    expect { described_class.call(**attributes) }.not_to change(OrdenFumigacion, :count)
    expect(described_class.call(**attributes)).to eq(first_order)
  end

  it "assigns an optional crop" do
    cultivo = create(:cultivo)

    orden = described_class.call(**attributes, cultivo_id: cultivo.id)

    expect(orden.cultivo).to eq(cultivo)
  end

  it "rejects a lote from another estancia" do
    attributes[:lote_id] = create(:lote).id

    expect { described_class.call(**attributes) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "rejects a decimal quantity" do
    attributes[:cantidad] = 20.5

    expect { described_class.call(**attributes) }.to raise_error(ArgumentError, "cantidad must be a positive integer")
  end
end
