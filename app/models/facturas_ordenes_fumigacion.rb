class FacturasOrdenesFumigacion < ApplicationRecord
  belongs_to :factura
  belongs_to :orden_fumigacion

  validates :importe, numericality: { greater_than_or_equal_to: 0 }
  validates :orden_fumigacion_id, uniqueness: true

  def precio
    hectareas = orden_fumigacion.lote_ordenes_fumigacion.sum { |lote_orden| (lote_orden.hectareas || 0).to_d }
    return if hectareas.zero?

    (importe / hectareas).round(2)
  end
end
