class Mcp::Tools::SearchCultivos < MCP::Tool
  tool_name "search_cultivos"
  title "Search crops"
  description "Busca cultivos registrados por nombre."

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
    result = {
      cultivos: Mcp::SearchByName.call(scope: Cultivo.all, query: query, limit: limit)
        .map { |cultivo| { id: cultivo.id, nombre: cultivo.nombre } }
    }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
