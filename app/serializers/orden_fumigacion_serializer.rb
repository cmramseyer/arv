class OrdenFumigacionSerializer
  include Rails.application.routes.url_helpers

  FULL_SHOW_KEYS = %w[id temp_lotes temp_hectareas estancia_id nombre_estancia lotes_ids nombre_lote hectareas estado_orden lotes info_trabajo datos_clima maquinista creator created_at updated_at orden_url]

  def initialize(orden_fumigacion)
    @orden_fumigacion = orden_fumigacion
  end

  def full_show
    {
      id: @orden_fumigacion.id,
      temp_lotes: @orden_fumigacion.temp_lotes,
      temp_hectareas: @orden_fumigacion.temp_hectareas,
      estancia_id: @orden_fumigacion.estancia_id,
      nombre_estancia: @orden_fumigacion.nombre_estancia,
      lotes_ids: @orden_fumigacion.lotes.map(&:id),
      nombre_lote: nombre_lote,
      hectareas: hectareas,
      estado_orden: @orden_fumigacion.estado_orden,
      lotes: lotes,
      info_trabajo: @orden_fumigacion.info_trabajo,
      fecha_trabajo: @orden_fumigacion.fecha_trabajo,
       datos_clima: @orden_fumigacion.datos_clima,
       maquinista: @orden_fumigacion.maquinista,
       creator: @orden_fumigacion.creator&.username,
       created_at: @orden_fumigacion.created_at,
      updated_at: @orden_fumigacion.updated_at,
      orden_url: @orden_fumigacion.orden_pdf.attached? ? rails_blob_url(@orden_fumigacion.orden_pdf, only_path: false) : nil,
      orden_pdf_fecha_creacion: @orden_fumigacion.orden_pdf&.created_at
    }
  end

  def hectareas
    @orden_fumigacion.lotes.any? ? @orden_fumigacion.lotes.sum(&:hectareas) : @orden_fumigacion.temp_hectareas
  end

  def nombre_estancia
    @orden_fumigacion.nombre_estancia
  end

  def nombre_lote
    @orden_fumigacion.lotes.any? ? @orden_fumigacion.lotes.map(&:nombre).join(", ") : @orden_fumigacion.temp_lotes
  end

  def lotes
    @orden_fumigacion.lote_ordenes_fumigacion.map do |lote_orden|
      lote = lote_orden.lote
      {
        id: lote_orden.id,
        lote_id: lote.id,
        nombre: lote.nombre,
        hectareas: lote.hectareas,
        estancia_id: lote.estancia_id,
        nombre_estancia: lote.estancia_nombre,
        dosis: lote_orden.dosis.map { |d| dosis(d) }
      }
    end
  end

  def dosis(d)
    {
      id: d.id,
      producto_id: d.producto.id,
      producto: d.producto.nombre,
      cantidad: d.cantidad,
      unidad_medida: d.producto.unidad_medida
    }
  end
end
