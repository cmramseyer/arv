class Mcp::Tools::ResolveOrder < MCP::Tool
  tool_name "resolve_order"
  title "Resolve order"
  description "Resuelve una estancia, lote y producto contra los registros antes de crear una orden."

  input_schema(
    properties: {
      estancia: { type: "string", minLength: 1 },
      lote: { type: "string", minLength: 1 },
      producto: { type: "string", minLength: 1 },
      cantidad: { type: "integer", minimum: 1 }
    },
    required: %w[ estancia lote producto cantidad ]
  )

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(estancia:, lote:, producto:, cantidad:, server_context:)
    estancia_result = resolve_estancia(estancia)
    lote_result = resolve_lote(lote, estancia_result)
    producto_result = resolve_producto(producto)
    result = {
      valid: resolved?(estancia_result, lote_result, producto_result) && valid_cantidad?(cantidad),
      estancia: estancia_result,
      lote: lote_result,
      producto: producto_result,
      cantidad: cantidad
    }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
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

  def self.resolved?(*results)
    results.all? { |result| result[:status] == "resolved" }
  end
  private_class_method :resolved?

  def self.valid_cantidad?(cantidad)
    cantidad.is_a?(Integer) && cantidad.positive?
  end
  private_class_method :valid_cantidad?
end
