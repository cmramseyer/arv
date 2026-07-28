class InformeOrden
  require "prawn"

  attr_reader :ordenes, :mes, :anio

  def initialize(ordenes, mes:, anio:)
    @ordenes = ordenes
    @mes = mes
    @anio = anio
  end

  def render
    Prawn::Document.new(page_layout: :landscape, margin: 36) do |pdf|
      pdf.text "Informe de órdenes - #{format('%02d/%04d', mes, anio)}", size: 16, style: :bold, align: :center
      pdf.move_down 16
      pdf.table(tabla, header: true, column_widths: column_widths) do
        row(0).font_style = :bold
        row(-1).font_style = :bold
        columns(4).align = :right
        cells.padding = 5
      end

      pdf.move_down 16
      if filas.empty?
        pdf.text "No hay órdenes terminadas para el período seleccionado."
      else
        pdf.text "Has. por maquinista", style: :bold
        totales_por_maquinista.each do |maquinista, hectareas|
          pdf.text "#{maquinista}: #{formatear_hectareas(hectareas)} Has."
        end
      end
    end.render
  end

  def filas
    @filas ||= ordenes.map do |orden|
      factura_orden = orden.facturas_ordenes_fumigacion.first

      {
        fecha: orden.fecha_trabajo.strftime("%d/%m"),
        orden: orden.id,
        estancia: orden.estancia.nombre,
        maquinista: orden.maquinista.nombre,
        hectareas: hectareas_de(orden),
        nro_factura: factura_orden&.factura&.nro_factura.to_s,
        nro_orden_cliente: factura_orden&.nro_orden_cliente.to_s
      }
    end
  end

  def total_hectareas
    filas.sum { |fila| fila[:hectareas] }
  end

  def totales_por_maquinista
    filas
      .group_by { |fila| fila[:maquinista] }
      .transform_values { |filas_maquinista| filas_maquinista.sum { |fila| fila[:hectareas] } }
      .sort.to_h
  end

  private

  def tabla
    [ headers, *filas.map { |fila| fila_para_tabla(fila) }, total ]
  end

  def headers
    [ "Fecha", "#Orden", "Estancia", "Maquinista", "Has.", "Nro factura", "Nro Orden" ]
  end

  def total
    [ "Total", "", "", "", formatear_hectareas(total_hectareas), "", "" ]
  end

  def fila_para_tabla(fila)
    [ fila[:fecha], fila[:orden], fila[:estancia], fila[:maquinista], formatear_hectareas(fila[:hectareas]), fila[:nro_factura], fila[:nro_orden_cliente] ]
  end

  def hectareas_de(orden)
    orden.lote_ordenes_fumigacion.sum { |lote_orden| (lote_orden.hectareas || 0).to_d }
  end

  def formatear_hectareas(hectareas)
    enteros, decimales = hectareas.to_d.to_s("F").split(".", 2)
    return enteros if decimales.blank? || decimales.to_i.zero?

    "#{enteros}.#{decimales.sub(/0+\z/, "")}"
  end

  def column_widths
    [ 55, 55, 150, 140, 60, 90, 100 ]
  end
end
