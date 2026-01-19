class FacturasController < ApplicationController
  def create
    factura = Factura.new(fecha_factura: Time.zone.now, nro_factura: factura_params[:nro_factura])
    ordenes_fumigacion = factura_params[:ordenes_fumigacion]

    if ordenes_fumigacion.blank?
      return render json: { ordenes_fumigacion: [ "no puede estar vacío" ] }, status: :unprocessable_entity
    end

    Factura.transaction do
      factura.save!
      ordenes_fumigacion.each do |orden|
        FacturasOrdenesFumigacion.create!(
          factura: factura,
          nro_orden_cliente: orden[:nro_orden_cliente],
          orden_fumigacion_id: orden[:id],
          importe: orden[:importe] || 0.0
        )
      end
    end

    render json: factura, status: :created
  rescue ActiveRecord::RecordInvalid => error
    render json: error.record.errors, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotUnique
    render json: { ordenes_fumigacion: [ "ya están facturadas" ] }, status: :unprocessable_entity
  end

  private

  def factura_params
    params.permit(:nro_factura, ordenes_fumigacion: %i[id importe nro_orden_cliente])
  end
end
