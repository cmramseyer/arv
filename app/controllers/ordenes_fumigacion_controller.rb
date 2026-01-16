class OrdenesFumigacionController < ApplicationController
  before_action :set_orden_fumigacion, only: %i[ show update terminar destroy pdf ]
  before_action :validate_pendiente_factura_params, only: %i[ pendiente_factura ]

  # GET /ordenes_fumigacion
  def index
    if estado_params?
      @ordenes_fumigacion = OrdenFumigacion.where(estado_orden: params[:estado])
    else
      @ordenes_fumigacion = OrdenFumigacion.all
    end


    render json: ordenes_fumigacion_json.map(&:full_show)
  end

  # GET /ordenes_fumigacion/1
  def show
    render json: orden_fumigacion_json.full_show
  end

  def pendiente_factura
    ordenes = OrdenesPendientesFactura.new(
      fecha_desde: params[:fecha_desde],
      fecha_hasta: params[:fecha_hasta]
    ).call

    reporte = OrdenesPendientesFacturaPorEstancia.new(ordenes).call

    render json: reporte
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
      render json: { error: "La orden ya está terminada" }, status: :unprocessable_entity
    elsif @orden_fumigacion.update(terminar_orden_fumigacion_params.merge(estado_orden: "terminada"))
      render json: @orden_fumigacion
    else
      render json: @orden_fumigacion.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ordenes_fumigacion/1
  def destroy
    @orden_fumigacion.destroy!
  end

  def pdf
    orden = OrdenFumigacion.find(params[:id])

    pdf_path = Rails.root.join("storage", "orden_#{orden.id}.pdf")
    Prawn::Document.generate(pdf_path) do |pdf|
      reporte = ReporteOrden.new(pdf, orden)
      reporte.generar
      reporte.pdf
    end

    orden.orden_pdf.attach(
      io: File.open(pdf_path),
      filename: "orden_#{orden.id}.pdf",
      content_type: "application/pdf"
    )

    # system("lp -d #{Configuracion.get('ip_impresora')} #{pdf_path}") if Configuracion.get('ip_impresora')
    render json: { orden_url: rails_blob_url(orden.orden_pdf, only_path: false), orden_pdf_fecha_creacion: orden.orden_pdf.created_at, message: "PDF generado e impreso correctamente" }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orden_fumigacion
      @orden_fumigacion = OrdenFumigacion.find(params.expect(:id))
    end

    def validate_pendiente_factura_params
      if params[:fecha_desde].blank? || params[:fecha_hasta].blank?
        render json: { error: "fecha_desde y fecha_hasta son requeridas" }, status: :unprocessable_entity
        return
      end

      Date.parse(params[:fecha_desde])
      Date.parse(params[:fecha_hasta])
    rescue Date::Error
      render json: { error: "fecha_desde y fecha_hasta deben ser fechas válidas" }, status: :unprocessable_entity
    end

    # Only allow a list of trusted parameters through.
    def orden_fumigacion_params
      params.require(:orden_fumigacion).permit(:temp_lotes, :temp_hectareas, :datos_clima, :info_trabajo, :creado_por, :estado_orden, :fecha_trabajo, :maquinista, lote_ids: [], dosis_attributes: [ :id, :producto_id, :cantidad, :_destroy ])
    end

    def terminar_orden_fumigacion_params
      params.require(:orden_fumigacion).permit(:info_trabajo, :fecha_trabajo, :maquinista)
    end

    def orden_fumigacion_json
      OrdenFumigacionSerializer.new(@orden_fumigacion)
    end

    def ordenes_fumigacion_json
      @ordenes_fumigacion.map { |of| OrdenFumigacionSerializer.new(of) }
    end

    def estado_params?
      [ "activa", "terminada" ].include?(params[:estado])
    end
end
