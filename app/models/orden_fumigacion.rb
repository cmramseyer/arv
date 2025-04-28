class OrdenFumigacion < ApplicationRecord
  belongs_to :lote
  has_many :dosis, dependent: :destroy
  accepts_nested_attributes_for :dosis, allow_destroy: true
  has_one_attached :orden_pdf

  validates :creado_por, presence: true
  enum :estado_orden, { activa: 0, terminada: 1 }
end
