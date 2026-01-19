class FacturasPagoController < ApplicationController
  before_action :set_factura, only: %i[ update ]

  def index
    facturas = Factura.pendientes_pago.includes(ordenes_fumigacion: { lotes: :estancia })

    render json: facturas.map { |factura| FacturaPagoSerializer.new(factura).full_show }
  end

  def update
    @factura.mark_as_paid!
    head :no_content
  end

  private

  def set_factura
    @factura = Factura.find(params.expect(:id))
  end
end
