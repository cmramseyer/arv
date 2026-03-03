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
            render_adjuntos_para_pdf(adjuntos_para_pdf(lote, orden))
          end

          render_adjuntos_para_pdf(adjuntos_orden_para_pdf(orden))
        else
          data_extra
        end
      end
    end
  end

  def adjuntos_para_pdf(lote, orden_fumigacion = orden)
    selected_ids = selected_attachment_ids_for_pdf(lote, orden_fumigacion)
    return [] if selected_ids.empty?

    lote.adjuntos.select { |adjunto| selected_ids.include?(adjunto.id) }
  end

  def adjuntos_orden_para_pdf(orden_fumigacion = orden)
    selected_ids = selected_attachment_ids_for_pdf(nil, orden_fumigacion)
    return [] if selected_ids.empty?

    orden_fumigacion.adjuntos.select { |adjunto| selected_ids.include?(adjunto.id) }
  end

  def selected_attachment_ids_for_pdf(lote, orden_fumigacion = orden)
    return [] if attachment_ids.blank?

    available_ids = orden_fumigacion.adjuntos.ids
    available_ids = (available_ids + lote.adjuntos.ids).uniq if lote.present?

    available_ids & Array(attachment_ids).map(&:to_i).uniq
  end

  def render_adjuntos_para_pdf(adjuntos)
    adjuntos.each do |adjunto|
      next unless adjunto.content_type&.start_with?("image")

      pdf.image StringIO.new(adjunto.download), fit: [ 500, 300 ]
    end
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
    fecha_creacion = orden.created_at_locale
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
    nombre_estancia = orden.nombre_estancia

    data = [
      [
        { content: nombre_estancia, size: font_size, align: :center, valign: :center },
        { content: cultivo_nombre(orden), size: font_size, align: :center, valign: :center }
      ]
    ]

    porcentaje_anchos = [ 0.5, 0.5 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla

    if orden.comentarios.present?

      comentarios_data = [
        [
          { content: "Comentarios: #{orden.comentarios}", size: font_size, align: :left, valign: :center }
        ]
      ]

      ReporteTabla.new(pdf: pdf, porcentaje_anchos: [ 1 ], data: comentarios_data).tabla
      pdf.move_down 10
    end

    lotes_y_dosis

    if orden.lotes.many?
      total_hectareas = orden.lote_ordenes_fumigacion.sum(&:hectareas)
      data = [ [
        { content: "Total", size: font_size, align: :center, valign: :center },
        { content: "#{total_hectareas} has", size: font_size, align: :center, valign: :center }
      ] ]

      porcentaje_anchos = [ 0.4, 0.3 ]

      ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla
    end

    pdf.move_down 20
  end

  def cultivo_nombre(orden)
    cultivo_nombre = orden.cultivo&.nombre || ""
    if orden.sensible? && cultivo_nombre.present?
      cultivo_nombre = "#{cultivo_nombre} (Sensible)"
    end
  end

  def lotes_y_dosis
    return if orden.lote_ordenes_fumigacion.blank?

    orden.lote_ordenes_fumigacion.each do |lote_orden|
      pdf.move_down 10
      data_lote(lote_orden)
      dosis_por_lote(lote_orden.dosis)
    end
  end

  def data_lote(lote_orden)
    data = [ [
      { content: "Lote #{lote_orden.nombre}", size: font_size, align: :center, valign: :center },
      { content: "#{lote_orden.hectareas} has", size: font_size, align: :center, valign: :center }
    ] ]

    porcentaje_anchos = [ 0.5, 0.5 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla
  end

  def data_estancia_cultivo_comentarios
    data = [
      [
        { content: orden.nombre_estancia, size: font_size, align: :center, valign: :center },
        { content: cultivo_nombre, size: font_size, align: :center, valign: :center }
      ]
    ]

    porcentaje_anchos = [ 0.5, 0.5 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla

    return if orden.comentarios.blank?

    comentarios_data = [
      [
        { content: "Comentarios: #{orden.comentarios}", size: font_size, align: :left, valign: :center }
      ]
    ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: [ 1 ], data: comentarios_data).tabla
  end

  def dosis_por_lote(dosis)
    return pdf.move_down 20 if dosis.blank?

    data = dosis.map.with_index do |d, index|
      [
        { content: index.zero? ? "Dosis" : "", size: font_size, align: :center, valign: :center },
        { content: "#{d.producto.nombre} ", size: font_size, align: :right, valign: :center },
        { content: " #{d.cantidad} #{d.producto.unidad_medida}", size: font_size, align: :left, valign: :center }
      ]
    end

    data = Array(data)

    porcentaje_anchos = [ 0.15, 0.45, 0.4 ]

    ReporteTabla.new(pdf: pdf, porcentaje_anchos: porcentaje_anchos, data: data).tabla_dosis

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
        { content: orden.fecha_trabajo_ddmmyyyy || "", size: font_size, align: :center, valign: :center }
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
