class LoteOrdenFumigacion < ApplicationRecord
  belongs_to :lote
  belongs_to :orden_fumigacion
  has_many :dosis, dependent: :destroy

  accepts_nested_attributes_for :dosis, allow_destroy: true

  delegate :estancia_id, :estancia_nombre, :nombre, to: :lote, allow_nil: false
  delegate :long, :lat, :link_mapa, to: :lote, allow_nil: true

  def hectareas
    return hectareas_reales if hectareas_reales.present? && hectareas_reales.to_f > 0

    lote.hectareas
  end
end
