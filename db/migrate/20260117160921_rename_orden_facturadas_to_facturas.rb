class RenameOrdenFacturadasToFacturas < ActiveRecord::Migration[8.0]
  def change
    rename_table :orden_facturadas, :facturas
    rename_index :facturas, "index_orden_facturadas_on_orden_fumigacion_id", "index_facturas_on_orden_fumigacion_id"
  end
end
