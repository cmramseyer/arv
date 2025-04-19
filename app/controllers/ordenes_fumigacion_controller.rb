class OrdenesFumigacionController < ApplicationController
  before_action :set_orden_fumigacion, only: %i[ show update terminar destroy ]

  # GET /ordenes_fumigacion
  def index
    @ordenes_fumigacion = OrdenFumigacion.all

    render json: @ordenes_fumigacion
  end

  # GET /ordenes_fumigacion/1
  def show
    render json: @orden_fumigacion
  end

  # POST /ordenes_fumigacion
  def create
    @orden_fumigacion = OrdenFumigacion.new(orden_fumigacion_params)

    if @orden_fumigacion.save
      render json: @orden_fumigacion, status: :created, location: @orden_fumigacion
    else
      render json: @orden_fumigacion.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ordenes_fumigacion/1
  def update
    if @orden_fumigacion.update(orden_fumigacion_params)
      render json: @orden_fumigacion
    else
      render json: @orden_fumigacion.errors, status: :unprocessable_entity
    end
  end

  def terminar
    if @orden_fumigacion.terminada?
      render json: {error: "La orden ya está terminada"}, status: :unprocessable_entity
    elsif @orden_fumigacion.update(terminar_orden_fumigacion_params.merge(estado_orden: 'terminada'))
      render json: @orden_fumigacion
    else
      render json: @orden_fumigacion.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ordenes_fumigacion/1
  def destroy
    @orden_fumigacion.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orden_fumigacion
      @orden_fumigacion = OrdenFumigacion.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def orden_fumigacion_params
      params.require(:orden_fumigacion).permit(:lote_id, :datos_clima, :info_trabajo, :creado_por, :estado_orden, :fecha_trabajo, :maquinista, dosis_attributes: [:producto_id, :cantidad])
    end

    def terminar_orden_fumigacion_params
      params.require(:orden_fumigacion).permit(:info_trabajo, :fecha_trabajo, :maquinista)
    end
end
