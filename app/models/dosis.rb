class Dosis < ApplicationRecord
  belongs_to :producto
  belongs_to :lote_orden_fumigacion

  validates :cantidad, numericality: { greater_than: 0 }
end
