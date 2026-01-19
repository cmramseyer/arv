class Factura < ApplicationRecord
  has_many :facturas_ordenes_fumigacion,
           class_name: "FacturasOrdenesFumigacion",
           dependent: :destroy
  has_many :ordenes_fumigacion, through: :facturas_ordenes_fumigacion

  validates :fecha_factura, presence: true
end
