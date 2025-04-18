class Producto < ApplicationRecord
  enum :unidad_medida, { kg: 0, gramos: 1, litros: 2, ml: 3 }
end
