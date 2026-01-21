class OrdenesPendientesFacturaPorEstancia
  def initialize(ordenes)
    @ordenes = ordenes
  end

  def call
    agrupadas = ordenes.group_by { |orden| orden.lotes.first&.estancia }

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
    orden.lotes.map do |lote|
      {
        lote_id: lote.id,
        hectareas: lote.hectareas,
        fecha_trabajo: orden.fecha_trabajo,
        maquinista: orden.maquinista&.nombre,
        orden_id: orden.id
      }
    end
  end
end
