class FacturasPagoController < ApplicationController
  def index
    facturas = Factura.pendientes_pago.includes(:facturas_ordenes_fumigacion, ordenes_fumigacion: { lotes: :estancia })

    render json: facturas.map { |factura| FacturaPagoSerializer.new(factura).full_show }
  end
end
