class OrdenesPendientesFacturaPorEstancia
  def initialize(ordenes)
    @ordenes = ordenes
  end

  def call
    agrupadas = ordenes.group_by(&:estancia)

    agrupadas.filter_map do |estancia, ordenes_estancia|
      next if estancia.nil?

      {
        id: estancia.id,
        nombre: estancia.nombre,
        data: ordenes_estancia.flat_map { |orden| datos_por_orden(orden) }
      }
    end
  end

  private

  attr_reader :ordenes

  def datos_por_orden(orden)
    orden.lote_ordenes_fumigacion.map do |lote_orden|
      {
        lote_id: lote_orden.lote_id,
        nombre: lote_orden.nombre,
        es_manual: lote_orden.manual?,
        hectareas: lote_orden.hectareas,
        fecha_trabajo: orden.fecha_trabajo,
        fecha_trabajo_ddmmyyyy: orden.fecha_trabajo_ddmmyyyy,
        maquinista: orden.maquinista&.nombre,
        orden_id: orden.id
      }
    end
  end
end
