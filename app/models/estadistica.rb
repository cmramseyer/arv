class Estadistica
  def initialize(fecha_desde:, fecha_hasta:)
    @fecha_desde = fecha_desde
    @fecha_hasta = fecha_hasta
  end

  def call
    {
      hectareas_por_propietario: hectareas_por_propietario,
      hectareas_por_maquinista: hectareas_por_maquinista,
      hectareas_por_cultivo: hectareas_por_cultivo
    }
  end

  private

  attr_reader :fecha_desde, :fecha_hasta

  def ordenes
    @ordenes ||= OrdenFumigacion
      .joins(:facturas)
      .where.not(facturas: { fecha_pago: nil })
      .where(fecha_trabajo: fecha_desde..fecha_hasta)
      .includes(:estancia, { lote_ordenes_fumigacion: :lote }, :maquinista, :cultivo)
      .distinct
  end

  def hectareas_por_propietario
    totales = Hash.new { |hash, key| hash[key] = 0.to_d }

    ordenes.each do |orden|
      next if orden.lote_ordenes_fumigacion.empty?

      orden.lote_ordenes_fumigacion.each do |lote_orden|
        totales[lote_orden.estancia_nombre] += lote_orden.hectareas
      end
    end

    totales.map do |nombre, hectareas|
      { nombre_estancia: nombre, hectareas: hectareas }
    end.sort_by { |item| -item[:hectareas].to_f }
  end

  def hectareas_por_maquinista
    totales = Hash.new { |hash, key| hash[key] = 0.to_d }

    ordenes.each do |orden|
      next if orden.lote_ordenes_fumigacion.empty?

      nombre = orden.maquinista&.nombre || "Sin clasificar"
      totales[nombre] += orden_hectareas(orden)
    end

    totales.map do |nombre, hectareas|
      { maquinista: nombre, hectareas: hectareas }
    end.sort_by { |item| -item[:hectareas].to_f }
  end

  def hectareas_por_cultivo
    totales = Hash.new { |hash, key| hash[key] = 0.to_d }

    ordenes.each do |orden|
      next if orden.lote_ordenes_fumigacion.empty?

      nombre = orden.cultivo&.nombre || "Sin clasificar"
      totales[nombre] += orden_hectareas(orden)
    end

    totales.map do |nombre, hectareas|
      { cultivo: nombre, hectareas: hectareas }
    end.sort_by { |item| -item[:hectareas].to_f }
  end

  def orden_hectareas(orden)
    orden.lote_ordenes_fumigacion.sum(&:hectareas)
  end
end
