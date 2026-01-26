class FacturaPagoSerializer
  def initialize(factura)
    @factura = factura
  end

  def full_show
    payload = {
      id: @factura.id,
      fecha_factura: @factura.fecha_factura,
      fecha_factura_ddmmyyyy: @factura.fecha_factura_ddmmyyyy,
      nro_factura: @factura.nro_factura,
      ordenes_fumigacion: ordenes_fumigacion
    }

    payload
  end

  private

  def ordenes_fumigacion
    detalles_por_orden = facturas_ordenes_fumigacion_detalles

    @factura.ordenes_fumigacion.map do |orden|
      detalles = detalles_por_orden[orden.id]
      {
        id: orden.id,
        importe: detalles[:importe],
        nro_orden_cliente: detalles[:nro_orden_cliente],
        nombre_estancia: orden.nombre_estancia,
        lotes: lotes(orden)
      }
    end
  end

  def facturas_ordenes_fumigacion_detalles
    @facturas_ordenes_fumigacion_detalles ||= @factura.facturas_ordenes_fumigacion.each_with_object({}) do |factura_orden, memo|
      memo[factura_orden.orden_fumigacion_id] = {
        importe: factura_orden.importe,
        nro_orden_cliente: factura_orden.nro_orden_cliente
      }
    end
  end

  def lotes(orden)
    orden.lote_ordenes_fumigacion.map do |lote_orden|
      {
        nombre: lote_orden.nombre,
        hectareas: lote_orden.hectareas
      }
    end
  end
end
