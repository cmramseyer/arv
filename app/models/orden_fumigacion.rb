class OrdenFumigacion < ApplicationRecord
  has_many :lote_ordenes_fumigacion, dependent: :destroy
  has_many :lotes, through: :lote_ordenes_fumigacion
  has_many :dosis, dependent: :destroy
  has_one :factura, dependent: :destroy
  accepts_nested_attributes_for :dosis, allow_destroy: true
  has_one_attached :orden_pdf

  validates :creado_por, presence: true
  enum :estado_orden, { activa: 0, terminada: 1 }

  validates :temp_lotes, presence: true, if: :needs_temp_fields?
  validates :temp_hectareas, presence: true, numericality: { greater_than: 0 }, if: :needs_temp_fields?

  validate :must_have_lotes_or_temp_fields

  def nombre_estancia
    lotes.map(&:estancia_nombre).uniq.join(", ")
  end

  def estancia_id
    lotes.map(&:estancia_id)&.uniq&.first
  end

  private

  def needs_temp_fields?
    lotes.empty?
  end

  def must_have_lotes_or_temp_fields
    if lotes.empty? && (temp_lotes.blank? || temp_hectareas.blank? || temp_hectareas.to_f == 0)
      errors.add(:base, "Debe tener al menos un lote, o temp_lotes y temp_hectareas deben estar completos y temp_hectareas distinto de cero.")
    end
  end
end
