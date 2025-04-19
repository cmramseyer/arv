class Producto < ApplicationRecord
  enum :unidad_medida, { kg: 0, gramos: 1, litros: 2, ml: 3 }
  validates :nombre, presence: true
  validates :tipo_producto, presence: true
end
