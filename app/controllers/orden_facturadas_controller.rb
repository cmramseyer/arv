class OrdenFacturadasController < ApplicationController
  def create
    orden_facturada = OrdenFacturada.new(
      orden_fumigacion_id: orden_facturada_params[:orden_fumigacion_id],
      fecha_factura: Time.zone.now
    )

    if orden_facturada.save
      render json: orden_facturada, status: :created
    else
      render json: orden_facturada.errors, status: :unprocessable_entity
    end
  end

  private

  def orden_facturada_params
    params.require(:orden_facturada).permit(:orden_fumigacion_id)
  end
end
