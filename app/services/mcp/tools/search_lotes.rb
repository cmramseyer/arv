class Mcp::Tools::SearchLotes < MCP::Tool
  tool_name "search_lotes"
  title "Search lots"
  description "Busca lotes de una estancia registrada antes de crear una orden."

  input_schema(
    properties: {
      estancia_id: { type: "integer", minimum: 1 },
      query: { type: "string", minLength: 1 },
      limit: { type: "integer", minimum: 1, maximum: 10 }
    },
    required: [ "estancia_id", "query" ]
  )

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(estancia_id:, query:, limit: 10, server_context:)
    lotes = Mcp::SearchByName.call(
      scope: Lote.where(estancia_id: estancia_id),
      query: query,
      limit: limit
    ).map { |lote| { id: lote.id, nombre: lote.nombre } }

    result = { lotes: lotes }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
