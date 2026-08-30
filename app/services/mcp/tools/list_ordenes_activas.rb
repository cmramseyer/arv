class Mcp::Tools::ListOrdenesActivas < MCP::Tool
  tool_name "list_ordenes_activas"
  title "List or count active fumigation orders"
  description "Usa esta herramienta para listar, consultar o conocer la cantidad de ordenes de fumigacion activas. Devuelve el total y el detalle de cada orden."

  input_schema(properties: {})

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(server_context:)
    orders = OrdenFumigacion.activa
      .includes(:estancia, lote_ordenes_fumigacion: :lote)
      .order(created_at: :desc)
      .map { |orden| order_details(orden) }

    result = {
      cantidad: orders.size,
      ordenes: orders
    }

    MCP::Tool::Response.new(
      [ { type: "text", text: result.to_json } ],
      structured_content: result
    )
  end

  def self.order_details(orden)
    {
      nro_orden: orden.id,
      estancia: { id: orden.estancia.id, nombre: orden.estancia.nombre },
      lotes: orden.lote_ordenes_fumigacion.map do |lote_orden|
        { id: lote_orden.lote_id, nombre: lote_orden.nombre }
      end,
      fecha_creacion: orden.created_at.iso8601
    }
  end
  private_class_method :order_details
end
