class Mcp::Tools::ListEstancias < MCP::Tool
  tool_name "list_estancias"
  title "List estancias"
  description "Devuelve todas las estancias registradas, ordenadas por nombre."

  input_schema(properties: {})

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(server_context:)
    result = {
      estancias: Estancia.order(:nombre, :id).map { |estancia| { id: estancia.id, nombre: estancia.nombre } }
    }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
