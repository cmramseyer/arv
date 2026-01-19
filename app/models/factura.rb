class Factura < ApplicationRecord
  has_many :facturas_ordenes_fumigacion,
           class_name: "FacturasOrdenesFumigacion",
           dependent: :destroy
  has_many :ordenes_fumigacion, through: :facturas_ordenes_fumigacion

  validates :fecha_factura, presence: true

  scope :pendientes_pago, -> { where.not(fecha_factura: nil).where(fecha_pago: nil) }

  def mark_as_paid!
    update!(fecha_pago: Time.zone.now)
  end
end
