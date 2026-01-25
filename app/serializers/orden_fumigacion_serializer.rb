class OrdenFumigacionSerializer
  include Rails.application.routes.url_helpers

  FULL_SHOW_KEYS = %w[id estancia_id nombre_estancia lotes_ids nombre_lote hectareas estado_orden lotes info_trabajo fecha_trabajo fecha_trabajo_ddmmyyyy datos_clima sensible comentarios maquinista creator created_at created_at_locale updated_at updated_at_locale orden_url orden_pdf_fecha_creacion orden_pdf_fecha_creacion_locale cultivo facturas]

  def initialize(orden_fumigacion)
    @orden_fumigacion = orden_fumigacion
  end

  def full_show
    {
      id: @orden_fumigacion.id,
      estancia_id: @orden_fumigacion.estancia_id,
      nombre_estancia: @orden_fumigacion.nombre_estancia,
      lotes_ids: @orden_fumigacion.lotes.map(&:id),
      nombre_lote: nombre_lote,
      hectareas: hectareas,
      estado_orden: @orden_fumigacion.estado_orden,
      lotes: lotes,
      info_trabajo: @orden_fumigacion.info_trabajo,
      fecha_trabajo: @orden_fumigacion.fecha_trabajo,
      fecha_trabajo_ddmmyyyy: @orden_fumigacion.fecha_trabajo_ddmmyyyy,
      datos_clima: @orden_fumigacion.datos_clima,
      sensible: @orden_fumigacion.sensible,
      comentarios: @orden_fumigacion.comentarios,
      maquinista: @orden_fumigacion.maquinista ? { id: @orden_fumigacion.maquinista.id, nombre: @orden_fumigacion.maquinista.nombre } : nil,
      creator: @orden_fumigacion.creator&.username,
      created_at: @orden_fumigacion.created_at,
      created_at_locale: @orden_fumigacion.created_at_locale,
      updated_at: @orden_fumigacion.updated_at,
      updated_at_locale: @orden_fumigacion.updated_at_locale,
      orden_url: @orden_fumigacion.orden_pdf.attached? ? rails_blob_url(@orden_fumigacion.orden_pdf, only_path: false) : nil,
      orden_pdf_fecha_creacion: @orden_fumigacion.orden_pdf&.created_at,
      orden_pdf_fecha_creacion_locale: @orden_fumigacion.orden_pdf_fecha_creacion_locale,
      cultivo: @orden_fumigacion.cultivo ? { id: @orden_fumigacion.cultivo.id, nombre: @orden_fumigacion.cultivo.nombre } : nil,
      facturas: facturas
    }
  end

  def hectareas
    @orden_fumigacion.lote_ordenes_fumigacion.sum(&:hectareas)
  end

  def nombre_estancia
    @orden_fumigacion.nombre_estancia
  end

  def nombre_lote
    @orden_fumigacion.lote_ordenes_fumigacion.map(&:nombre).join(", ")
  end

  def lotes
    @orden_fumigacion.lote_ordenes_fumigacion.map do |lote_orden|
      {
        id: lote_orden.id,
        lote_id: lote_orden.lote_id,
        nombre: lote_orden.nombre,
        hectareas: lote_orden.hectareas,
        estancia_id: lote_orden.estancia_id,
        nombre_estancia: lote_orden.estancia_nombre,
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

  def facturas
    @orden_fumigacion.facturas_ordenes_fumigacion.map do |factura_orden|
      factura = factura_orden.factura
      {
        nro_factura: factura&.nro_factura,
        nro_orden_cliente: factura_orden.nro_orden_cliente,
        fecha_factura: factura&.fecha_factura,
        fecha_pago: factura&.fecha_pago
      }
    end
  end
end
