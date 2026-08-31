class Mcp::Tools::ListCultivos < MCP::Tool
  tool_name "list_cultivos"
  title "List crops"
  description "Devuelve todos los cultivos registrados, ordenados por nombre."

  input_schema(properties: {})

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(server_context:)
    result = {
      cultivos: Cultivo.order(:nombre, :id).map { |cultivo| { id: cultivo.id, nombre: cultivo.nombre } }
    }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
