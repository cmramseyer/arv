class OrdenFumigacion < ApplicationRecord
  belongs_to :lote
  has_many :dosis, dependent: :destroy
  accepts_nested_attributes_for :dosis, allow_destroy: true
  validates :dosis, length: { minimum: 1, message: "debe tener al menos una dosis" }
  # has_many :adjuntos, as: :objeto, dependent: :destroy
  
  validates :creado_por, presence: true
  enum :estado_orden, { activa: 0, terminada: 1 }
end
