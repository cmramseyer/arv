class CreateOrdenFacturadas < ActiveRecord::Migration[8.0]
  def change
    create_table :orden_facturadas do |t|
      t.references :orden_fumigacion, null: false, foreign_key: true
      t.datetime :fecha_factura
      t.datetime :fecha_pago

      t.timestamps
    end
  end
end
