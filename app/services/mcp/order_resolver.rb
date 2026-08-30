class Mcp::OrderResolver
  def self.call(estancia:, lote:, producto:, cantidad:, cultivo: nil)
    estancia_result = resolve_estancia(estancia)
    lote_result = resolve_lote(lote, estancia_result)
    producto_result = resolve_producto(producto)
    cultivo_result = resolve_cultivo(cultivo) if cultivo.present?
    results = [ estancia_result, lote_result, producto_result, cultivo_result ].compact

    {
      valid: results.all? { |result| result[:status] == "resolved" } && valid_cantidad?(cantidad),
      estancia: estancia_result,
      lote: lote_result,
      producto: producto_result,
      cultivo: cultivo_result,
      cantidad: cantidad
    }
  end

  def self.resolve_estancia(name)
    Mcp::NameMatcher.call(scope: Estancia.all, query: name) do |estancia|
      { id: estancia.id, nombre: estancia.nombre }
    end
  end
  private_class_method :resolve_estancia

  def self.resolve_lote(name, estancia_result)
    return { status: "not_searched", reason: "estancia_not_resolved", matches: [] } unless estancia_result[:status] == "resolved"

    Mcp::NameMatcher.call(scope: Lote.where(estancia_id: estancia_result[:id]), query: name) do |lote|
      { id: lote.id, nombre: lote.nombre }
    end
  end
  private_class_method :resolve_lote

  def self.resolve_producto(name)
    Mcp::NameMatcher.call(scope: Producto.all, query: name) do |producto|
      { id: producto.id, nombre: producto.nombre, unidad_medida: producto.unidad_medida }
    end
  end
  private_class_method :resolve_producto

  def self.resolve_cultivo(name)
    Mcp::NameMatcher.call(scope: Cultivo.all, query: name) do |cultivo|
      { id: cultivo.id, nombre: cultivo.nombre }
    end
  end
  private_class_method :resolve_cultivo

  def self.valid_cantidad?(cantidad)
    cantidad.is_a?(Integer) && cantidad.positive?
  end
  private_class_method :valid_cantidad?
end
