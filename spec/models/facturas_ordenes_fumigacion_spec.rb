require "rails_helper"

RSpec.describe FacturasOrdenesFumigacion, type: :model do
  it "validates uniqueness of orden_fumigacion_id" do
    orden = create(:orden_fumigacion, :terminada)
    create(:facturas_ordenes_fumigacion, orden_fumigacion: orden)

    duplicate = build(:facturas_ordenes_fumigacion, orden_fumigacion: orden)

    expect(duplicate).not_to be_valid
  end
end
