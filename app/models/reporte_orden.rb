class ReporteOrden < Prawn::Document
  require "prawn"

  attr_accessor :pdf, :orden, :font_size, :attachment_ids
  def initialize(pdf, orden, attachment_ids: nil)
    @pdf = pdf
    @orden = orden
    @attachment_ids = attachment_ids
    @font_size = 20
  end

  def generar
    pdf.repeat :all do
      dibujar_header
    end

    dibujar_body

    string = "página <page> / <total>"
    options = { at: [ pdf.bounds.right - 220, 22 ],
      width: 150,
      align: :right,
      page_filter: (1..11),
      start_count_at: 1 }
    pdf.number_pages string, options
    pdf
  end

  def dibujar_body
    pdf.canvas do
      pdf.bounding_box [ pdf.bounds.left + 20, pdf.bounds.top - 80 ], width: pdf.bounds.width - 40 do
        body

        # if params[:incluir_mapas].present?

        if orden.activa?
          orden.lotes.each do |lote|
            adjuntos_para_pdf(lote).each do |adjunto|
              if adjunto.content_type&.start_with?("image")
                pdf.image StringIO.new(adjunto.download), fit: [ 500, 300 ]
              end
            end
          end
        else
          data_extra
        end
      end
    end
  end

  def adjuntos_para_pdf(lote)
    return [] if attachment_ids.nil?

    lote.adjuntos.select { |adjunto| attachment_ids.include?(adjunto.id) }
  end

  def dibujar_header
    pdf.canvas do
      pdf.bounding_box [ pdf.bounds.left + 20, pdf.bounds.top - 20 ], width: pdf.bounds.width - 40 do
        header
      end
    end
  end

  def header
    # image = Path::LogoPng

    label_arv = "ARV"
    label_orden = "Orden de Trabajo ##{orden.id}"
    fecha_creacion = orden.created_at.in_time_zone("America/Argentina/Buenos_Aires").strftime("%d/%m/%y %H:%M")
    estancia = orden.nombre_estancia

    # opciones/parametros

    porcentaje_anchos = [ 0.3, 0.4, 0.3 ]


    data = [
      [
        { content: label_arv, size: font_size, align: :center, valign: :center },
        { content: label_orden, size: font_size, align: :center, valign: :center },
        { content: fecha_creacion, size: font_size, align: :center, valign: :center }
      ]
    ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla

    pdf.move_down 20
  end

  def body
    nombre_estancia = orden.lotes.present? ? orden.nombre_estancia : "Estancia Temporal"

    data = [
      [
        { content: nombre_estancia, size: font_size, align: :center, valign: :center }
      ]
    ]

    porcentaje_anchos = [ 0.7 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla

    lotes_y_dosis

    if orden.lotes.many?
      total_hectareas = orden.lotes.sum(&:hectareas)
      data = [ [
        { content: "Total", size: font_size, align: :center, valign: :center },
        { content: "#{total_hectareas} has", size: font_size, align: :center, valign: :center }
      ] ]

      porcentaje_anchos = [ 0.4, 0.3 ]

      ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla
    end

    pdf.move_down 20
  end

  def lotes_y_dosis
    if orden.lotes.present?
      orden.lote_ordenes_fumigacion.each do |lote_orden|
        data_lote(lote_orden.lote)
        dosis_por_lote(lote_orden.dosis)
      end
    else
      data = [ [
        { content: "Lotes #{orden.temp_lotes}", size: font_size, align: :center, valign: :center },
        { content: "#{orden.temp_hectareas} has", size: font_size, align: :center, valign: :center }
      ] ]

      porcentaje_anchos = [ 0.4, 0.3 ]

      ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla
      dosis_por_lote([])
    end
  end

  def data_lote(lote)
    data = [ [
      { content: "Lote #{lote.nombre}", size: font_size, align: :center, valign: :center },
      { content: "#{lote.hectareas} has", size: font_size, align: :center, valign: :center }
    ] ]

    porcentaje_anchos = [ 0.4, 0.3 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla
  end

  def dosis_por_lote(dosis)
    data = [
      [
        { content: "Dosis", size: font_size, align: :center, valign: :center }
      ]
    ]

    porcentaje_anchos = [ 0.7 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla

    return pdf.move_down 20 if dosis.blank?

    data = dosis.map do |d|
      [
        { content: "#{d.producto.nombre}", size: font_size, align: :center, valign: :center },
        { content: "#{d.cantidad} #{d.producto.unidad_medida}", size: font_size, align: :center, valign: :center }
      ]
    end

    data = Array(data)

    porcentaje_anchos = [ 0.4, 0.3 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla

    pdf.move_down 20
  end

  def data_extra
    data = [
      [
        { content: "Maquinista", size: font_size, align: :center, valign: :center },
        { content: orden.maquinista&.nombre || "", size: font_size, align: :center, valign: :center }
      ],
      [
        { content: "Fecha Trabajo", size: font_size, align: :center, valign: :center },
        { content: orden.fecha_trabajo.strftime("%d/%m/%y"), size: font_size, align: :center, valign: :center }
      ],
      [
        { content: "Info Trabajo", size: font_size, align: :center, valign: :center },
        { content: orden.info_trabajo, size: font_size, align: :center, valign: :center }
      ]
    ]

    porcentaje_anchos = [ 0.3, 0.4 ]


    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla

    pdf.move_down 20
  end
end
