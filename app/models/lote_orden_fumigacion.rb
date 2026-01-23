class LoteOrdenFumigacion < ApplicationRecord
  belongs_to :lote
  belongs_to :orden_fumigacion
  has_many :dosis, dependent: :destroy

  accepts_nested_attributes_for :dosis, allow_destroy: true

  def nombre
    lote.nombre
  end

  def lat
    lote.lat
  end

  def long
    lote.long
  end

  def link_mapa
    lote.link_mapa
  end

  def estancia_id
    lote.estancia_id
  end

  def estancia_nombre
    lote.estancia_nombre
  end

  def hectareas
    return hectareas_reales if hectareas_reales.present? && hectareas_reales.to_f > 0

    lote.hectareas
  end
end
