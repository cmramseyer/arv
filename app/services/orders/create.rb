class Orders::Create
  def self.call(...)
    new(...).call
  end

  def initialize(request_id:, estancia_id:, lote_id:, producto_id:, cantidad:, creator:, cultivo_id: nil)
    @request_id = request_id
    @estancia_id = estancia_id
    @lote_id = lote_id
    @producto_id = producto_id
    @cantidad = cantidad
    @creator = creator
    @cultivo_id = cultivo_id
  end

  def call
    OrdenFumigacion.transaction do
      OrdenFumigacion.find_by(source_request_id: @request_id) || create_order
    end
  rescue ActiveRecord::RecordNotUnique
    OrdenFumigacion.find_by!(source_request_id: @request_id)
  end

  private
    def create_order
      estancia = Estancia.find(@estancia_id)
      lote = estancia.lotes.find(@lote_id)
      producto = Producto.find(@producto_id)
      cultivo = Cultivo.find(@cultivo_id) if @cultivo_id.present?
      validate_cantidad!

      orden = OrdenFumigacion.new(
        creator: @creator,
        estancia: estancia,
        cultivo: cultivo,
        source_request_id: @request_id
      )
      lote_orden = orden.lote_ordenes_fumigacion.build(lote: lote)
      lote_orden.dosis.build(producto: producto, cantidad: @cantidad)
      orden.save!
      orden
    end

    def validate_cantidad!
      return if @cantidad.is_a?(Integer) && @cantidad.positive?

      raise ArgumentError, "cantidad must be a positive integer"
    end
end
