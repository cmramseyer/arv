class LoteOrdenFumigacion < ApplicationRecord
  belongs_to :lote
  belongs_to :orden_fumigacion
end
