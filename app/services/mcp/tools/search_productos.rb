class Mcp::Tools::SearchProductos < MCP::Tool
  tool_name "search_productos"
  title "Search products"
  description "Busca productos registrados por nombre antes de crear una orden."

  input_schema(
    properties: {
      query: { type: "string", minLength: 1 },
      limit: { type: "integer", minimum: 1, maximum: 10 }
    },
    required: [ "query" ]
  )

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(query:, limit: 10, server_context:)
    productos = Mcp::SearchByName.call(scope: Producto.all, query: query, limit: limit)
      .map do |producto|
        { id: producto.id, nombre: producto.nombre, unidad_medida: producto.unidad_medida }
      end

    result = { productos: productos }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
