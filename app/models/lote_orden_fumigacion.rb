class LoteOrdenFumigacion < ApplicationRecord
  belongs_to :lote
  belongs_to :orden_fumigacion
  has_many :dosis, dependent: :destroy

  accepts_nested_attributes_for :dosis, allow_destroy: true
end
