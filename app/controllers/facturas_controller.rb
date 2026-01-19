class FacturasController < ApplicationController
  def create
    factura = Factura.new(fecha_factura: Time.zone.now)
    orden_fumigacion_ids = factura_params[:orden_fumigacion_ids]

    if orden_fumigacion_ids.blank?
      return render json: { orden_fumigacion_ids: [ "no puede estar vacío" ] }, status: :unprocessable_entity
    end

    if factura.save
      factura.ordenes_fumigacion << OrdenFumigacion.where(id: orden_fumigacion_ids)
      render json: factura, status: :created
    else
      render json: factura.errors, status: :unprocessable_entity
    end
  end

  private

  def factura_params
    params.require(:factura).permit(orden_fumigacion_ids: [])
  end
end
