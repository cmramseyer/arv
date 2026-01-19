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

  describe ".pendientes_pago" do
    it "returns only facturas pendientes" do
      factura_pendiente = create(:factura, fecha_factura: Time.zone.now, fecha_pago: nil)
      create(:factura, fecha_pago: Time.zone.now)
      factura_sin_fecha = create(:factura, fecha_pago: nil)
      factura_sin_fecha.update_column(:fecha_factura, nil)

      expect(described_class.pendientes_pago).to contain_exactly(factura_pendiente)
    end
  end

  describe "#mark_as_paid!" do
    it "sets fecha_pago" do
      factura = create(:factura, fecha_pago: nil)
      now = Time.zone.now

      factura.mark_as_paid!

      expect(factura.reload.fecha_pago).to be >= now
    end
  end
end
