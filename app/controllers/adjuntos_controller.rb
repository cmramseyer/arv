class AdjuntosController < ApplicationController
  def index
    if params[:orden_fumigacion_id].blank?
      return render json: { error: "orden_fumigacion_id es requerido" }, status: :unprocessable_entity
    end

    orden = OrdenFumigacion
      .includes(lotes: { adjuntos_attachments: :blob })
      .find(params[:orden_fumigacion_id])

    adjuntos = orden.lotes.flat_map(&:adjuntos).uniq(&:id)

    render json: adjuntos.map { |adjunto| AdjuntoSerializer.new(adjunto).show }
  end
end
