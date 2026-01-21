class AdjuntosController < ApplicationController
  before_action :set_lote, only: %i[ destroy ]
  before_action :set_adjunto, only: %i[ destroy ]

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

  # DELETE /lotes/:lote_id/adjuntos/:id
  def destroy
    @adjunto.purge
    head :no_content
  end

  private
    def set_lote
      @lote = Lote.find(params.expect(:lote_id))
    end

    def set_adjunto
      @adjunto = @lote.adjuntos.find(params.expect(:id))
    end
end
