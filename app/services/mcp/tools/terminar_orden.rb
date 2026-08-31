class Mcp::Tools::TerminarOrden < MCP::Tool
  tool_name "terminar_orden"
  title "Complete fumigation order"
  description "Marca una orden de fumigacion como terminada. La fecha debe ser absoluta en formato YYYY-MM-DD."

  input_schema(
    properties: {
      nro_orden: { type: "integer", minimum: 1 },
      maquinista: { type: "string", minLength: 1 },
      fecha: { type: "string", pattern: "^\\d{4}-\\d{2}-\\d{2}$" }
    },
    required: %w[ nro_orden maquinista fecha ]
  )

  annotations(
    read_only_hint: false,
    destructive_hint: true,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(nro_orden:, maquinista:, fecha:, server_context:)
    maquinista_resolution = resolve_maquinista(maquinista)
    return clarification_response(maquinista_resolution) unless maquinista_resolution[:status] == "resolved"

    result = Orders::Terminar.call(
      nro_orden:,
      attributes: {
        maquinista_id: maquinista_resolution[:id],
        fecha_trabajo: Date.iso8601(fecha)
      }
    )
    return invalid_response(result.orden) if result.status == "invalid"

    response = {
      order_id: result.orden.id,
      status: result.status,
      orden: OrdenFumigacionSerializer.new(result.orden).full_show
    }
    MCP::Tool::Response.new(
      [ { type: "text", text: response.to_json } ],
      structured_content: response
    )
  rescue ActiveRecord::RecordNotFound, Date::Error => error
    response = { error: error.message }

    MCP::Tool::Response.new(
      [ { type: "text", text: response.to_json } ],
      error: true,
      structured_content: response
    )
  end

  def self.resolve_maquinista(nombre)
    Mcp::NameMatcher.call(scope: Maquinista.all, query: nombre) do |maquinista|
      { id: maquinista.id, nombre: maquinista.nombre }
    end
  end
  private_class_method :resolve_maquinista

  def self.clarification_response(maquinista_resolution)
    response = { status: "needs_clarification", maquinista: maquinista_resolution }

    MCP::Tool::Response.new(
      [ { type: "text", text: response.to_json } ],
      structured_content: response
    )
  end
  private_class_method :clarification_response

  def self.invalid_response(orden)
    response = { error: orden.errors.to_hash }

    MCP::Tool::Response.new(
      [ { type: "text", text: response.to_json } ],
      error: true,
      structured_content: response
    )
  end
  private_class_method :invalid_response
end
