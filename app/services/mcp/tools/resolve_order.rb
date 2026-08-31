class Mcp::Tools::ResolveOrder < MCP::Tool
  tool_name "resolve_order"
  title "Resolve order"
  description "Resuelve estancia, lote, producto y cultivo opcional contra los registros antes de crear una orden."

  input_schema(
    properties: {
      estancia: { type: "string", minLength: 1 },
      lote: { type: "string", minLength: 1 },
      producto: { type: "string", minLength: 1 },
      cultivo: { type: "string", minLength: 1 },
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

  def self.call(estancia:, lote:, producto:, cantidad:, cultivo: nil, server_context:)
    result = Mcp::OrderResolver.call(
      estancia: estancia,
      lote: lote,
      producto: producto,
      cultivo: cultivo,
      cantidad: cantidad
    )

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
end
