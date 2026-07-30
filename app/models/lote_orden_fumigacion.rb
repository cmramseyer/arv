class LoteOrdenFumigacion < ApplicationRecord
  belongs_to :lote, optional: true
  belongs_to :orden_fumigacion
  has_many :dosis, dependent: :destroy

  accepts_nested_attributes_for :dosis, allow_destroy: true

  delegate :long, :lat, :link_mapa, to: :lote, allow_nil: true

  validate :has_lote_or_nombre_manual
  validate :lote_belongs_to_estancia
  validates :hectareas_reales, numericality: { greater_than: 0 }, if: :manual?

  def manual?
    lote_id.blank?
  end

  def nombre
    manual? ? nombre_manual : lote&.nombre
  end

  def estancia
    orden_fumigacion.estancia
  end

  def estancia_id
    estancia.id
  end

  def estancia_nombre
    estancia.nombre
  end

  def hectareas
    return hectareas_reales if manual?
    return hectareas_reales if hectareas_reales.present? && hectareas_reales.to_f > 0

    lote.hectareas
  end

  private

  def has_lote_or_nombre_manual
    if lote_id.present? && nombre_manual.present?
      errors.add(:base, "Debe seleccionar un lote o indicar un nombre manual, no ambos.")
    elsif lote_id.blank? && nombre_manual.blank?
      errors.add(:base, "Debe seleccionar un lote o indicar un nombre manual.")
    elsif lote_id.present? && lote.nil?
      errors.add(:lote, "no existe.")
    end
  end

  def lote_belongs_to_estancia
    return if lote.blank? || orden_fumigacion.blank? || lote.estancia_id == orden_fumigacion.estancia_id

    errors.add(:lote, "debe pertenecer a la estancia de la orden.")
  end
end
