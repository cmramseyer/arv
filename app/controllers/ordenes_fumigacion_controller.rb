class OrdenesFumigacionController < ApplicationController
  before_action :set_orden_fumigacion, only: %i[ show update terminar destroy pdf ]

  # GET /ordenes_fumigacion
  def index
    @ordenes_fumigacion = OrdenFumigacion.all

    render json: ordenes_fumigacion_json.map(&:full_show)
  end

  # GET /ordenes_fumigacion/1
  def show
    render json: orden_fumigacion_json.full_show
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
    orden = OrdenFumigacion.includes(:lote, :dosis, lote: :estancia).find(params[:id])

    pdf_path = Rails.root.join("storage", "orden_#{orden.id}.pdf")
    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.text "Orden: #{orden.id}"
      pdf.text "Orden Creada: #{orden.created_at.strftime('%d/%m/%Y %H:%M')} Por: #{orden.creado_por}"
      pdf.text "Estancia: #{orden.lote.estancia.nombre}"
      pdf.text "Lote: #{orden.lote.nombre}"
      pdf.text "Dosis:"
      orden.dosis.each_with_index do |dosi, idx|
        pdf.text "#{idx + 1} - #{dosi.producto.nombre}, #{dosi.cantidad}#{dosi.producto.unidad_medida}"
      end
      # if params[:incluir_mapas].present?
      orden.lote.adjuntos.each do |adjunto|
        if adjunto.content_type&.start_with?("image")
          pdf.image StringIO.new(adjunto.download), fit: [ 500, 300 ]
        end
      end
      pdf
    end

    orden.orden_pdf.attach(
      io: File.open(pdf_path),
      filename: "orden_#{orden.id}.pdf",
      content_type: 'application/pdf'
    )

    # system("lp -d #{Configuracion.get('ip_impresora')} #{pdf_path}") if Configuracion.get('ip_impresora')
    render json: { orden_url: rails_blob_url(orden.orden_pdf, only_path: false), orden_pdf_fecha_creacion: orden.orden_pdf.created_at, message: "PDF generado e impreso correctamente" }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orden_fumigacion
      @orden_fumigacion = OrdenFumigacion.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def orden_fumigacion_params
      params.require(:orden_fumigacion).permit(:lote_id, :datos_clima, :info_trabajo, :creado_por, :estado_orden, :fecha_trabajo, :maquinista, dosis_attributes: [ :id, :producto_id, :cantidad, :_destroy ])
    end

    def terminar_orden_fumigacion_params
      params.require(:orden_fumigacion).permit(:info_trabajo, :fecha_trabajo, :maquinista)
    end

    def orden_fumigacion_json
      OrdenFumigacionSerializer.new(@orden_fumigacion)
    end

    def ordenes_fumigacion_json
      @ordenes_fumigacion.map {|of| OrdenFumigacionSerializer.new(of)}
    end
end
