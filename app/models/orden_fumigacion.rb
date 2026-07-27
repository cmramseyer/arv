class OrdenFumigacion < ApplicationRecord
  LOCALE_TIME_ZONE = "America/Argentina/Buenos_Aires"

  has_many :lote_ordenes_fumigacion, dependent: :destroy
  has_many :lotes, through: :lote_ordenes_fumigacion
  has_many :facturas_ordenes_fumigacion,
           class_name: "FacturasOrdenesFumigacion",
           dependent: :destroy
  has_many :facturas, through: :facturas_ordenes_fumigacion
  accepts_nested_attributes_for :lote_ordenes_fumigacion, allow_destroy: true
  has_one_attached :orden_pdf
  has_many_attached :adjuntos

  belongs_to :creator, class_name: "User"
  belongs_to :estancia
  belongs_to :maquinista, optional: true
  belongs_to :cultivo, optional: true
  validates :creator, presence: true
  enum :estado_orden, { activa: 0, terminada: 1 }

  validate :must_have_lotes

  def nombre_estancia
    estancia.nombre
  end

  def fecha_trabajo_ddmmyyyy
    fecha_trabajo&.strftime("%d/%m/%Y")
  end

  def created_at_locale
    format_datetime_locale(created_at)
  end

  def updated_at_locale
    format_datetime_locale(updated_at)
  end

  def orden_pdf_fecha_creacion_locale
    format_datetime_locale(orden_pdf&.created_at)
  end

  private

  def format_datetime_locale(value)
    value&.in_time_zone(LOCALE_TIME_ZONE)&.strftime("%d/%m/%Y %H:%M")
  end

  def must_have_lotes
    return if lotes_asignados.any?

    errors.add(:base, "Debe tener al menos un lote.")
  end

  def lotes_asignados
    lote_ordenes_fumigacion.reject(&:marked_for_destruction?)
  end
end
