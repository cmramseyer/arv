class LoteSerializer
  FULL_SHOW_KEYS = %w[id nombre estancia_id nombre_estancia lat long link_mapa hectareas created_at updated_at adjuntos]

  def initialize(lote)
    @lote = lote
  end

  def show
    {
      id: @lote.id,
      nombre: @lote.nombre,
      estancia_id: @lote.estancia_id,
      nombre_estancia: @lote.estancia_nombre,
      lat: @lote.lat,
      long: @lote.long,
      link_mapa: @lote.link_mapa,
      hectareas: @lote.hectareas,
      created_at: @lote.created_at,
      updated_at: @lote.updated_at
    }
  end

  def full_show
    {
      id: @lote.id,
      nombre: @lote.nombre,
      estancia_id: @lote.estancia_id,
      nombre_estancia: @lote.estancia_nombre,
      lat: @lote.lat,
      long: @lote.long,
      link_mapa: @lote.link_mapa,
      hectareas: @lote.hectareas,
      adjuntos: @lote.adjuntos.map { |adjunto| LoteAdjuntoSerializer.new(adjunto).show },
      created_at: @lote.created_at,
      updated_at: @lote.updated_at
    }
  end
end
