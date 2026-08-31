class EstadisticasController < ApplicationController
  before_action :validate_estadisticas_params

  def index
    render json: Estadistica.new(fecha_desde: @fecha_desde, fecha_hasta: @fecha_hasta).call
  end

  private

  def validate_estadisticas_params
    if params[:fecha_desde].blank? || params[:fecha_hasta].blank?
      render json: { error: "fecha_desde y fecha_hasta son requeridas" }, status: :unprocessable_entity
      return
    end

    @fecha_desde = Date.parse(params[:fecha_desde])
    @fecha_hasta = Date.parse(params[:fecha_hasta])
  rescue Date::Error
    render json: { error: "fecha_desde y fecha_hasta deben ser fechas válidas" }, status: :unprocessable_entity
  end
end
