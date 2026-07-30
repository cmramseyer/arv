class Estancia < ApplicationRecord
  validates :nombre, presence: true
  has_many :lotes
  has_many :ordenes_fumigacion
end
