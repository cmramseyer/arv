class OrdenFumigacionSerializer
  include Rails.application.routes.url_helpers

  FULL_SHOW_KEYS = %w(id estancia_id nombre_estancia lote_id nombre_lote hectareas estado_orden dosis info_trabajo datos_clima maquinista creado_por created_at updated_at orden_url)

  def initialize(orden_fumigacion)
    @orden_fumigacion = orden_fumigacion
  end

  def full_show
    {
      id: @orden_fumigacion.id,
      estancia_id: @orden_fumigacion.lote.estancia.id,
      nombre_estancia: @orden_fumigacion.lote.estancia.nombre,
      lote_id: @orden_fumigacion.lote.id,
      nombre_lote: @orden_fumigacion.lote.nombre, 
      hectareas: @orden_fumigacion.lote.hectareas,
      estado_orden: @orden_fumigacion.estado_orden,
      dosis: @orden_fumigacion.dosis.map {|d| dosis(d)},
      info_trabajo: @orden_fumigacion.info_trabajo,
      fecha_trabajo: @orden_fumigacion.fecha_trabajo,
      datos_clima: @orden_fumigacion.datos_clima,
      maquinista: @orden_fumigacion.maquinista,
      creado_por: @orden_fumigacion.creado_por,
      created_at: @orden_fumigacion.created_at,
      updated_at: @orden_fumigacion.updated_at,
      orden_url: @orden_fumigacion.orden_pdf.attached? ? rails_blob_url(@orden_fumigacion.orden_pdf, only_path: false) : nil,
      orden_pdf_fecha_creacion: @orden_fumigacion.orden_pdf&.created_at
    }
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