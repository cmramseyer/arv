require "rails_helper"

RSpec.describe OrdenesPendientesFactura do
  describe "#call" do
    it "returns terminadas within range" do
      orden_terminada = create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2025, 10, 15))
      orden_fuera = create(:orden_fumigacion, :terminada, fecha_trabajo: Date.new(2025, 11, 1))
      orden_activa = create(:orden_fumigacion, :activa, fecha_trabajo: Date.new(2025, 10, 15))

      resultados = described_class.new(
        fecha_desde: Date.new(2025, 10, 1),
        fecha_hasta: Date.new(2025, 10, 31)
      ).call

      expect(resultados).to contain_exactly(orden_terminada)
      expect(resultados).not_to include(orden_fuera, orden_activa)
    end
  end
end
