class AddNroOrdenClienteToFacturasOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    add_column :facturas_ordenes_fumigacion, :nro_orden_cliente, :string
  end
end
