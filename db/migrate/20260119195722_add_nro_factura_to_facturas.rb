class AddNroFacturaToFacturas < ActiveRecord::Migration[8.0]
  def change
    add_column :facturas, :nro_factura, :string
  end
end
