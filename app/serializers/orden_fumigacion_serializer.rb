class OrdenFumigacionSerializer
  include Rails.application.routes.url_helpers

  FULL_SHOW_KEYS = %w(id nombre_estancia nombre_lote hectareas estado_orden dosis info_trabajo datos_clima maquinista creado_por created_at updated_at)

  def initialize(orden_fumigacion)
    @orden_fumigacion = orden_fumigacion
  end

  def full_show
    {
      id: @orden_fumigacion.id,
      nombre_estancia: @orden_fumigacion.lote.estancia.nombre,
      nombre_lote: @orden_fumigacion.lote.nombre, 
      hectareas: @orden_fumigacion.lote.hectareas,
      estado_orden: @orden_fumigacion.estado_orden,
      dosis: @orden_fumigacion.dosis.map {|d| dosis(d)},
      info_trabajo: @orden_fumigacion.info_trabajo,
      datos_clima: @orden_fumigacion.datos_clima,
      maquinista: @orden_fumigacion.maquinista,
      creado_por: @orden_fumigacion.creado_por,
      created_at: @orden_fumigacion.created_at,
      updated_at: @orden_fumigacion.updated_at
    }
  end

  def dosis(d)
    {
      producto: d.producto.nombre,
      cantidad: d.cantidad,
      unidad_medida: d.producto.unidad_medida
    }
  end
end