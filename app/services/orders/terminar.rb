class Orders::Terminar
  Result = Struct.new(:orden, :status, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  def initialize(nro_orden:, attributes:)
    @nro_orden = nro_orden
    @attributes = attributes
  end

  def call
    orden = OrdenFumigacion.includes(:estancia, adjuntos_attachments: :blob).find(@nro_orden)
    return Result.new(orden:, status: "already_terminated") if orden.terminada?

    if orden.update(@attributes.merge(estado_orden: "terminada"))
      Result.new(orden:, status: "terminated")
    else
      Result.new(orden:, status: "invalid")
    end
  end
end
