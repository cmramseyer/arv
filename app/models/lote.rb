class Lote < ApplicationRecord
  belongs_to :estancia
  has_many_attached :adjuntos
  validates :nombre, presence: true
end
