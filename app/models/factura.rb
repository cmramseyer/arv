class Factura < ApplicationRecord
  has_many :facturas_ordenes_fumigacion,
           class_name: "FacturasOrdenesFumigacion",
           dependent: :destroy
  has_many :ordenes_fumigacion, through: :facturas_ordenes_fumigacion

  validates :fecha_factura, presence: true

  scope :pendientes_pago, -> { where.not(fecha_factura: nil).where(fecha_pago: nil) }

  def fecha_factura_ddmmyyyy
    fecha_factura&.strftime("%d/%m/%Y")
  end

  def fecha_pago_ddmmyyyy
    fecha_pago&.strftime("%d/%m/%Y")
  end
end
