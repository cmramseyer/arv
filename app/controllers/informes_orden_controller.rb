class InformesOrdenController < ApplicationController
  before_action :set_periodo

  def show
    ordenes = OrdenFumigacion
      .where(estado_orden: "terminada", fecha_trabajo: @fecha_desde..@fecha_hasta)
      .where.not(maquinista_id: nil)
      .includes(
        :estancia,
        :maquinista,
        lote_ordenes_fumigacion: :lote,
        facturas_ordenes_fumigacion: :factura
      )
      .order(:fecha_trabajo, :id)

    pdf = InformeOrden.new(ordenes, mes: @mes, anio: @anio).render
    filename = "informe_orden_#{format('%02d_%04d', @mes, @anio)}.pdf"
    pdf_path = Rails.root.join("storage", filename)

    File.binwrite(pdf_path, pdf)

    send_file pdf_path,
              filename: filename,
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def set_periodo
    @mes = Integer(params.require(:mes))
    @anio = Integer(params.require(:anio))
    raise ArgumentError unless (1..12).cover?(@mes) && @anio.positive?

    @fecha_desde = Date.new(@anio, @mes, 1)
    @fecha_hasta = @fecha_desde.end_of_month
  rescue ActionController::ParameterMissing, ArgumentError, TypeError
    render json: { error: "mes y anio deben ser valores válidos" }, status: :unprocessable_entity
  end
end
