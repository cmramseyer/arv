class OrdenesPendientesFactura
  def initialize(fecha_desde:, fecha_hasta:)
    @fecha_desde = fecha_desde
    @fecha_hasta = fecha_hasta
  end

  def call
    scope = OrdenFumigacion
      .includes(lotes: :estancia)
      .left_outer_joins(:orden_facturada)
      .where(estado_orden: "terminada")
      .where(orden_facturadas: { fecha_factura: nil })

    return scope if fecha_desde.blank? && fecha_hasta.blank?

    scope.where(fecha_trabajo: fecha_desde..fecha_hasta)
  end

  private

  attr_reader :fecha_desde, :fecha_hasta
end
