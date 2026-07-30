require "rails_helper"

RSpec.describe OrdenesPendientesFacturaPorEstancia do
  describe "#call" do
    it "groups ordenes by estancia" do
      estancia = create(:estancia, nombre: "Estancia 1")
      lote_1 = create(:lote, estancia: estancia, hectareas: 22)
      lote_2 = create(:lote, estancia: estancia, hectareas: 10)
      orden = create(:orden_fumigacion, :terminada, lotes: [ lote_1, lote_2 ], fecha_trabajo: Date.new(2025, 10, 22))

      resultado = described_class.new([ orden ]).call

      expect(resultado).to eq([
        {
          id: estancia.id,
          nombre: "Estancia 1",
          data: [
            {
              lote_id: lote_1.id,
              nombre: lote_1.nombre,
              es_manual: false,
              hectareas: lote_1.hectareas,
              fecha_trabajo: orden.fecha_trabajo,
              fecha_trabajo_ddmmyyyy: orden.fecha_trabajo_ddmmyyyy,
              maquinista: orden.maquinista&.nombre,
              orden_id: orden.id
            },
            {
              lote_id: lote_2.id,
              nombre: lote_2.nombre,
              es_manual: false,
              hectareas: lote_2.hectareas,
              fecha_trabajo: orden.fecha_trabajo,
              fecha_trabajo_ddmmyyyy: orden.fecha_trabajo_ddmmyyyy,
              maquinista: orden.maquinista&.nombre,
              orden_id: orden.id
            }
          ]
        }
      ])
    end

    it "groups manual lotes by the orden estancia" do
      estancia = create(:estancia, nombre: "Estancia manual")
      orden = build(:orden_fumigacion, :terminada, estancia: estancia, lotes: [], fecha_trabajo: Date.new(2025, 10, 22))
      orden.lote_ordenes_fumigacion.build(nombre_manual: "Lote manual", hectareas_reales: 12.5)
      orden.save!

      resultado = described_class.new([ orden ]).call

      expect(resultado).to eq([
        {
          id: estancia.id,
          nombre: "Estancia manual",
          data: [
            {
              lote_id: nil,
              nombre: "Lote manual",
              es_manual: true,
              hectareas: 12.5,
              fecha_trabajo: orden.fecha_trabajo,
              fecha_trabajo_ddmmyyyy: orden.fecha_trabajo_ddmmyyyy,
              maquinista: orden.maquinista&.nombre,
              orden_id: orden.id
            }
          ]
        }
      ])
    end
  end
end
