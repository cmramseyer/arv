class FacturasController < ApplicationController
  def create
    factura = Factura.new(
      orden_fumigacion_id: factura_params[:orden_fumigacion_id],
      fecha_factura: Time.zone.now
    )

    if factura.save
      render json: factura, status: :created
    else
      render json: factura.errors, status: :unprocessable_entity
    end
  end

  private

  def factura_params
    params.require(:factura).permit(:orden_fumigacion_id)
  end
end
