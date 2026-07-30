require 'rails_helper'

RSpec.describe LoteOrdenFumigacion, type: :model do
  subject(:lote_orden) { build(:lote_orden_fumigacion, orden_fumigacion: orden) }

  let(:orden) { build(:orden_fumigacion) }

  it "requires a lote or a manual name" do
    expect(lote_orden).to be_invalid
    expect(lote_orden.errors[:base]).to include("Debe seleccionar un lote o indicar un nombre manual.")
  end

  it "requires positive hectares for manual lotes" do
    lote_orden.nombre_manual = "Lote manual"
    lote_orden.hectareas_reales = 0

    expect(lote_orden).to be_invalid
    expect(lote_orden.errors[:hectareas_reales]).to include("must be greater than 0")
  end

  it "does not allow a lote and a manual name together" do
    lote_orden.lote = create(:lote, estancia: orden.estancia)
    lote_orden.nombre_manual = "Lote manual"

    expect(lote_orden).to be_invalid
    expect(lote_orden.errors[:base]).to include("Debe seleccionar un lote o indicar un nombre manual, no ambos.")
  end
end
