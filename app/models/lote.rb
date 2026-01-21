class Lote < ApplicationRecord
  belongs_to :estancia
  has_many :lote_ordenes_fumigacion
  has_many :ordenes_fumigacion, through: :lote_ordenes_fumigacion
  has_many_attached :adjuntos
  validates :nombre, presence: true

  delegate :nombre, to: :estancia, prefix: true
end
