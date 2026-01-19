class CreateFacturasOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    create_table :facturas_ordenes_fumigacion do |t|
      t.references :factura, null: false, foreign_key: true
      t.references :orden_fumigacion, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
