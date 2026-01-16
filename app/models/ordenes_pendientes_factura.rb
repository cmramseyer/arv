class OrdenesPendientesFactura
  def initialize(fecha_desde:, fecha_hasta:)
    @fecha_desde = fecha_desde
    @fecha_hasta = fecha_hasta
  end

  def call
    OrdenFumigacion
      .includes(lotes: :estancia)
      .where(estado_orden: "terminada")
      .where(fecha_trabajo: fecha_desde..fecha_hasta)
      .select { |orden| !orden_facturada?(orden) }
  end

  private

  attr_reader :fecha_desde, :fecha_hasta

  def orden_facturada?(orden)
    false
  end
end
