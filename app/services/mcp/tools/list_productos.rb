class Mcp::Tools::ListProductos < MCP::Tool
  tool_name "list_productos"
  title "List products"
  description "Devuelve todos los productos registrados, ordenados por nombre."

  input_schema(properties: {})

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(server_context:)
    result = {
      productos: Producto.order(:nombre, :id).map do |producto|
        { id: producto.id, nombre: producto.nombre, unidad_medida: producto.unidad_medida }
      end
    }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
