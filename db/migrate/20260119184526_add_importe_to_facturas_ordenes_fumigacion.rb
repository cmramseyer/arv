class AddImporteToFacturasOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    add_column :facturas_ordenes_fumigacion, :importe, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end
