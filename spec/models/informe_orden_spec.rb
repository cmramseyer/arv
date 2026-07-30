require "rails_helper"

RSpec.describe InformeOrden do
  describe "#formatear_hectareas" do
    subject(:informe) { described_class.new([], mes: 7, anio: 2026) }

    it "omits unnecessary decimal places" do
      expect(informe.send(:formatear_hectareas, 12.to_d)).to eq("12")
      expect(informe.send(:formatear_hectareas, 12.5.to_d)).to eq("12.5")
      expect(informe.send(:formatear_hectareas, 12.25.to_d)).to eq("12.25")
    end
  end

  describe "#filas" do
    it "includes factura and manual lotes in the totals" do
      estancia = create(:estancia, nombre: "Estancia 1")
      maquinista = create(:maquinista, nombre: "Maquinista 1")
      orden = build(
        :orden_fumigacion,
        :terminada,
        estancia: estancia,
        maquinista: maquinista,
        lotes: [],
        fecha_trabajo: Date.new(2026, 7, 12)
      )
      orden.lote_ordenes_fumigacion.build(nombre_manual: "Manual 1", hectareas_reales: 7.25)
      orden.lote_ordenes_fumigacion.build(nombre_manual: "Manual 2", hectareas_reales: 5)
      orden.save!

      factura = create(:factura, ordenes_fumigacion: [], nro_factura: "FAC-001")
      create(
        :facturas_ordenes_fumigacion,
        factura: factura,
        orden_fumigacion: orden,
        nro_orden_cliente: "ORD-001"
      )
      informe = described_class.new([ orden ], mes: 7, anio: 2026)

      expect(informe.filas).to eq([
        {
          fecha: "12/07",
          orden: orden.id,
          estancia: "Estancia 1",
          maquinista: "Maquinista 1",
          hectareas: 12.25.to_d,
          nro_factura: "FAC-001",
          nro_orden_cliente: "ORD-001"
        }
      ])
      expect(informe.total_hectareas).to eq(12.25.to_d)
      expect(informe.totales_por_maquinista).to eq("Maquinista 1" => 12.25.to_d)
      expect(informe.render).to start_with("%PDF")
    end
  end
end
