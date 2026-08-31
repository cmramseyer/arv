class OrdenesFumigacionController < ApplicationController
  before_action :set_orden_fumigacion, only: %i[ show update terminar destroy pdf ]
  before_action :validate_pendiente_factura_params, only: %i[ pendiente_factura ]

  # GET /ordenes_fumigacion
  def index
    @ordenes_fumigacion = OrdenFumigacion.all

    @ordenes_fumigacion = @ordenes_fumigacion.where(estado_orden: params[:estado]) if estado_params?
    @ordenes_fumigacion = @ordenes_fumigacion.where(cultivo_id: params[:cultivo_id]) if params[:cultivo_id].present?
    @ordenes_fumigacion = @ordenes_fumigacion.where(maquinista_id: params[:maquinista_id]) if params[:maquinista_id].present?
    @ordenes_fumigacion = @ordenes_fumigacion.where("fecha_trabajo >= ?", params[:fecha_desde]) if params[:fecha_desde].present?
    @ordenes_fumigacion = @ordenes_fumigacion.where("fecha_trabajo <= ?", params[:fecha_hasta]) if params[:fecha_hasta].present?
    @ordenes_fumigacion = @ordenes_fumigacion.joins(:lote_ordenes_fumigacion)
      .where(lote_ordenes_fumigacion: { lote_id: params[:lote_id] }) if params[:lote_id].present?
    @ordenes_fumigacion = @ordenes_fumigacion.where(estancia_id: params[:estancia_id]) if params[:estancia_id].present?
    if params[:nro_orden_cliente].present?
      @ordenes_fumigacion = filter_case_insensitive(
        @ordenes_fumigacion.joins(:facturas_ordenes_fumigacion),
        "facturas_ordenes_fumigacion.nro_orden_cliente",
        params[:nro_orden_cliente]
      )
    end

    if params[:nro_factura].present?
      @ordenes_fumigacion = filter_case_insensitive(
        @ordenes_fumigacion.joins(:facturas),
        "facturas.nro_factura",
        params[:nro_factura]
      )
    end
    @ordenes_fumigacion = @ordenes_fumigacion
      .includes(
        :estancia,
        :maquinista,
        :cultivo,
        lote_ordenes_fumigacion: { lote: :estancia },
        adjuntos_attachments: :blob
      )
      .distinct
      .order(id: :desc)

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
    @orden_fumigacion = OrdenFumigacion.new(orden_fumigacion_params.merge(creator_id: current_user.id))

    if @orden_fumigacion.save
      render json: OrdenFumigacionSerializer.new(@orden_fumigacion).full_show, status: :created, location: @orden_fumigacion
    else
      render json: @orden_fumigacion.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ordenes_fumigacion/1
  def update
    attributes = orden_fumigacion_params
    adjuntos = attributes.delete(:adjuntos)

    @orden_fumigacion.adjuntos.attach(adjuntos) if adjuntos.present?

    if @orden_fumigacion.update(attributes)
      render json: OrdenFumigacionSerializer.new(@orden_fumigacion).full_show
    else
      render json: @orden_fumigacion.errors, status: :unprocessable_entity
    end
  end

  def terminar
    result = Orders::Terminar.call(
      nro_orden: @orden_fumigacion.id,
      attributes: terminar_orden_fumigacion_params
    )

    if result.status == "already_terminated"
      render json: { error: "La orden ya está terminada" }, status: :unprocessable_entity
    elsif result.status == "terminated"
      render json: OrdenFumigacionSerializer.new(result.orden).full_show
    else
      render json: result.orden.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ordenes_fumigacion/1
  def destroy
    @orden_fumigacion.destroy!
  end

  def pdf
    orden = OrdenFumigacion.find(params[:id])
    attachment_ids = params.key?(:attachment_ids) ? Array(params[:attachment_ids]).map(&:to_i).uniq : nil

    pdf_path = Rails.root.join("storage", "orden_#{orden.id}.pdf")
    Prawn::Document.generate(pdf_path) do |pdf|
      reporte = ReporteOrden.new(pdf, orden, attachment_ids: attachment_ids)
      reporte.generar
      reporte.pdf
    end

    orden.orden_pdf.attach(
      io: File.open(pdf_path),
      filename: "orden_#{orden.id}.pdf",
      content_type: "application/pdf"
    )

    # system("lp -d #{Configuracion.get('ip_impresora')} #{pdf_path}") if Configuracion.get('ip_impresora')
    render json: {
      orden_url: rails_blob_url(orden.orden_pdf, only_path: false),
      orden_pdf_fecha_creacion: orden.orden_pdf.created_at,
      orden_pdf_fecha_creacion_locale: orden.orden_pdf_fecha_creacion_locale,
      message: "PDF generado e impreso correctamente"
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orden_fumigacion
      @orden_fumigacion = OrdenFumigacion
        .includes(:estancia, adjuntos_attachments: :blob)
        .find(params.expect(:id))
    end

    def validate_pendiente_factura_params
      if params[:fecha_desde].blank? && params[:fecha_hasta].blank?
        return
      end

      if params[:fecha_desde].blank? || params[:fecha_hasta].blank?
        render json: { error: "fecha_desde y fecha_hasta son requeridas" }, status: :unprocessable_entity
        return
      end

      Date.parse(params[:fecha_desde])
      Date.parse(params[:fecha_hasta])
    rescue Date::Error
      render json: { error: "fecha_desde y fecha_hasta deben ser fechas válidas" }, status: :unprocessable_entity
      throw :abort
    end

    # Only allow a list of trusted parameters through.
    def orden_fumigacion_params
      permitted = params.require(:orden_fumigacion).permit(
        :datos_clima,
        :info_trabajo,
        :sensible,
        :comentarios,
        :creator_id,
        :estado_orden,
        :fecha_trabajo,
        :estancia_id,
        :maquinista_id,
        :cultivo_id,
        adjuntos: [],
        lotes: [ :id, :lote_id, :nombre_manual, :hectareas_reales, :_destroy, { dosis: [ :id, :producto_id, :cantidad, :_destroy ] } ]
      )

      lotes = permitted.delete(:lotes)
      if lotes
        permitted[:lote_ordenes_fumigacion_attributes] = lotes.map do |lote|
          lote_attributes = lote.to_h
          dosis = lote_attributes.delete("dosis")
          lote_attributes["dosis_attributes"] = dosis if dosis
          assign_hectareas_reales(lote_attributes)
          lote_attributes
        end
      end

      permitted
    end

    def assign_hectareas_reales(lote_attributes)
      return if lote_attributes["_destroy"].to_s == "1"

      hectareas_reales = lote_attributes["hectareas_reales"]
      return if hectareas_reales.present? && hectareas_reales.to_f > 0

      lote = resolve_lote(lote_attributes)
      return if lote.nil?

      lote_attributes["hectareas_reales"] = lote.hectareas
    end

    def resolve_lote(lote_attributes)
      if lote_attributes["lote_id"].present?
        Lote.find_by(id: lote_attributes["lote_id"])
      elsif lote_attributes["id"].present?
        LoteOrdenFumigacion.includes(:lote).find_by(id: lote_attributes["id"])&.lote
      end
    end

    def terminar_orden_fumigacion_params
      params.require(:orden_fumigacion).permit(:datos_clima, :info_trabajo, :fecha_trabajo, :maquinista_id)
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

    def filter_case_insensitive(scope, column, value)
      pattern = "%#{value.strip}%"

      if ActiveRecord::Base.connection.adapter_name.match?(/sqlite/i)
        scope.where("LOWER(#{column}) LIKE ?", pattern.downcase)
      else
        scope.where("#{column} ILIKE ?", pattern)
      end
    end
end
