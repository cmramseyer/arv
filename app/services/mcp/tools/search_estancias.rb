class Mcp::Tools::SearchEstancias < MCP::Tool
  tool_name "search_estancias"
  title "Search estancias"
  description "Busca estancias registradas por nombre antes de usar sus datos en otra operación."

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
    estancias = Mcp::SearchByName.call(scope: Estancia.all, query: query, limit: limit)
      .map { |estancia| { id: estancia.id, nombre: estancia.nombre } }

    result = { estancias: estancias }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
