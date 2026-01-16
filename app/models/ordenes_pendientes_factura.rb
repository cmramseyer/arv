class OrdenesPendientesFactura
  def initialize(fecha_desde:, fecha_hasta:)
    @fecha_desde = fecha_desde
    @fecha_hasta = fecha_hasta
  end

  def call
    OrdenFumigacion
      .includes(lotes: :estancia)
      .left_outer_joins(:orden_facturada)
      .where(estado_orden: "terminada")
      .where(fecha_trabajo: fecha_desde..fecha_hasta)
      .where(orden_facturadas: { fecha_factura: nil })
  end

  private

  attr_reader :fecha_desde, :fecha_hasta
end
