class FacturaPagoSerializer
  def initialize(factura, include_fecha_pago: false)
    @factura = factura
    @include_fecha_pago = include_fecha_pago
  end

  def full_show
    payload = {
      id: @factura.id,
      fecha_factura: @factura.fecha_factura,
      ordenes_fumigacion: ordenes_fumigacion
    }

    payload[:fecha_pago] = @factura.fecha_pago if @include_fecha_pago

    payload
  end

  private

  def ordenes_fumigacion
    importes_por_orden = facturas_ordenes_fumigacion_importes

    @factura.ordenes_fumigacion.map do |orden|
      {
        id: orden.id,
        importe: importes_por_orden[orden.id],
        nombre_estancia: orden.nombre_estancia,
        lotes: lotes(orden)
      }
    end
  end

  def facturas_ordenes_fumigacion_importes
    @facturas_ordenes_fumigacion_importes ||= @factura.facturas_ordenes_fumigacion.each_with_object({}) do |factura_orden, memo|
      memo[factura_orden.orden_fumigacion_id] = factura_orden.importe
    end
  end

  def lotes(orden)
    orden.lotes.map do |lote|
      {
        nombre: lote.nombre,
        hectareas: lote.hectareas
      }
    end
  end
end
