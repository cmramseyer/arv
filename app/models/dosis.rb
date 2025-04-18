class Dosis < ApplicationRecord
  belongs_to :producto
  belongs_to :orden_fumigacion
end
