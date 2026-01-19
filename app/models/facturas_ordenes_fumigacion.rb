class FacturasOrdenesFumigacion < ApplicationRecord
  belongs_to :factura
  belongs_to :orden_fumigacion

  validates :orden_fumigacion_id, uniqueness: true
end
