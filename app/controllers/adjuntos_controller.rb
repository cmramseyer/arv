class AdjuntosController < ApplicationController
  before_action :set_lote, only: %i[ create destroy ]

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

  # POST /lotes/:lote_id/adjuntos
  def create
    @lote.adjuntos.attach(adjunto_params)
    adjunto = @lote.adjuntos.last
    render json: AdjuntoSerializer.new(adjunto).show, status: :created
  end

  # DELETE /lotes/:lote_id/adjuntos/:id
  def destroy
    @adjunto = @lote.adjuntos.attachments.find_by(blob_id: params.expect(:id))
    if @adjunto.nil?
      render json: { error: "Adjunto not found" }, status: :not_found
    else
      @adjunto.purge
      head :no_content
    end
  end

  private
    def set_lote
      @lote = Lote.find(params.expect(:lote_id))
    end

    def adjunto_params
      params.require(:adjunto)
    end
end
