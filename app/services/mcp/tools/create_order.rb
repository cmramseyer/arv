class Mcp::Tools::CreateOrder < MCP::Tool
  tool_name "create_order"
  title "Create order"
  description "Crea una orden desde nombres de negocio. Resuelve y valida estancia, lote, producto y cultivo opcional internamente."

  input_schema(
    properties: {
      request_id: { type: "string", minLength: 1 },
      estancia: { type: "string", minLength: 1 },
      lote: { type: "string", minLength: 1 },
      producto: { type: "string", minLength: 1 },
      cultivo: { type: "string", minLength: 1 },
      cantidad: { type: "integer", minimum: 1 }
    },
    required: %w[ request_id estancia lote producto cantidad ]
  )

  annotations(
    read_only_hint: false,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(request_id:, estancia:, lote:, producto:, cantidad:, cultivo: nil, server_context:)
    Rails.logger.info("MCP create_order started for #{request_id}")
    resolution = Mcp::OrderResolver.call(
      estancia: estancia,
      lote: lote,
      producto: producto,
      cultivo: cultivo,
      cantidad: cantidad
    )
    return clarification_response(request_id:, resolution:) unless resolution[:valid]

    orden = Orders::Create.call(
      request_id: request_id,
      estancia_id: resolution.dig(:estancia, :id),
      lote_id: resolution.dig(:lote, :id),
      producto_id: resolution.dig(:producto, :id),
      cultivo_id: resolution.dig(:cultivo, :id),
      cantidad: cantidad,
      creator: server_context.fetch(:creator)
    )
    result = { order_id: orden.id, status: "created", resolution: resolution }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ArgumentError => error
    Rails.logger.error("MCP create_order failed for #{request_id}: #{error.class}: #{error.message}")
    Rails.logger.error(error.full_message(highlight: false))
    result = { error: error.message }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      error: true,
      structured_content: result
    )
  rescue StandardError => error
    Rails.logger.error("MCP create_order crashed for #{request_id}: #{error.class}: #{error.message}")
    Rails.logger.error(error.full_message(highlight: false))
    raise
  end

  def self.clarification_response(request_id:, resolution:)
    Rails.logger.info("MCP create_order requires clarification for #{request_id}: #{resolution.inspect}")
    result = { status: "needs_clarification", resolution: resolution }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end
  private_class_method :clarification_response
end
