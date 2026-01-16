class OrdenFacturada < ApplicationRecord
  belongs_to :orden_fumigacion

  validates :fecha_factura, presence: true
end
