require "rails_helper"

RSpec.describe Factura, type: :model do
  it "is valid with fecha_factura" do
    factura = build(:factura)

    expect(factura).to be_valid
  end

  it "requires fecha_factura" do
    factura = build(:factura, fecha_factura: nil)

    expect(factura).not_to be_valid
  end

  it "associates multiple ordenes_fumigacion" do
    ordenes = create_list(:orden_fumigacion, 2, :terminada)
    factura = create(:factura, ordenes_fumigacion: ordenes)

    expect(factura.ordenes_fumigacion).to match_array(ordenes)
  end
end
