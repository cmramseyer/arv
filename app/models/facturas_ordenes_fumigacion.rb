class FacturasOrdenesFumigacion < ApplicationRecord
  belongs_to :factura
  belongs_to :orden_fumigacion

  validates :importe, numericality: { greater_than_or_equal_to: 0 }
  validates :orden_fumigacion_id, uniqueness: true
end
