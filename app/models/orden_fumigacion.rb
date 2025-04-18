class OrdenFumigacion < ApplicationRecord
  belongs_to :lote
  has_many :dosis, dependent: :destroy
  accepts_nested_attributes_for :dosis, allow_destroy: true
  # has_many :adjuntos, as: :objeto, dependent: :destroy

  enum :estado_orden, { activa: 0, terminada: 1 }
end
