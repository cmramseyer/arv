require "rails_helper"

RSpec.describe FacturasOrdenesFumigacion, type: :model do
  it "validates uniqueness of orden_fumigacion_id" do
    orden = create(:orden_fumigacion, :terminada)
    create(:facturas_ordenes_fumigacion, orden_fumigacion: orden)

    duplicate = build(:facturas_ordenes_fumigacion, orden_fumigacion: orden)

    expect(duplicate).not_to be_valid
  end

  describe "#precio" do
    it "divides importe by the total hectares of the orden" do
      estancia = create(:estancia)
      orden = build(:orden_fumigacion, :terminada, estancia: estancia, lotes: [])
      orden.lote_ordenes_fumigacion.build(nombre_manual: "Manual", hectareas_reales: 7.25)
      orden.lote_ordenes_fumigacion.build(nombre_manual: "Manual dos", hectareas_reales: 5)
      orden.save!
      factura_orden = create(:facturas_ordenes_fumigacion, orden_fumigacion: orden, importe: 123.5)

      expect(factura_orden.precio).to eq(10.08.to_d)
    end

    it "returns nil when the orden has no hectares" do
      orden = create(:orden_fumigacion, :terminada)
      orden.lote_ordenes_fumigacion.update_all(hectareas_reales: 0)
      orden.lotes.update_all(hectareas: 0)
      factura_orden = create(:facturas_ordenes_fumigacion, orden_fumigacion: orden, importe: 123.5)

      expect(factura_orden.precio).to be_nil
    end
  end
end
