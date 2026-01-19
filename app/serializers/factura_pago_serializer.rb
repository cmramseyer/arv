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
    @factura.ordenes_fumigacion.map do |orden|
      {
        id: orden.id,
        nombre_estancia: orden.nombre_estancia,
        lotes: lotes(orden)
      }
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
