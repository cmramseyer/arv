class Mcp::Tools::CreateOrder < MCP::Tool
  tool_name "create_order"
  title "Create order"
  description "Crea una orden con un lote persistido y una dosis de producto."

  input_schema(
    properties: {
      request_id: { type: "string", minLength: 1 },
      estancia_id: { type: "integer", minimum: 1 },
      lote_id: { type: "integer", minimum: 1 },
      producto_id: { type: "integer", minimum: 1 },
      cantidad: { type: "integer", minimum: 1 }
    },
    required: %w[ request_id estancia_id lote_id producto_id cantidad ]
  )

  annotations(
    read_only_hint: false,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(request_id:, estancia_id:, lote_id:, producto_id:, cantidad:, server_context:)
    orden = Orders::Create.call(
      request_id: request_id,
      estancia_id: estancia_id,
      lote_id: lote_id,
      producto_id: producto_id,
      cantidad: cantidad,
      creator: server_context.fetch(:creator)
    )
    result = { order_id: orden.id, status: "created" }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ArgumentError => error
    result = { error: error.message }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      error: true,
      structured_content: result
    )
  end
end
