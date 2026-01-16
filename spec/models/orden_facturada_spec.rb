require "rails_helper"

RSpec.describe OrdenFacturada, type: :model do
  it "is valid with fecha_factura" do
    orden_facturada = build(:orden_facturada)

    expect(orden_facturada).to be_valid
  end

  it "requires fecha_factura" do
    orden_facturada = build(:orden_facturada, fecha_factura: nil)

    expect(orden_facturada).not_to be_valid
  end
end
