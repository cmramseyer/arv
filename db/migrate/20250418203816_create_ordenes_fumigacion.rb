class CreateOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    create_table :ordenes_fumigacion do |t|
      t.references :lote, null: false, foreign_key: true
      t.text :datos_clima
      t.text :info_trabajo
      t.string :creado_por
      t.integer :estado_orden, default: 0, null: false
      t.date :fecha_trabajo
      t.string :maquinista

      t.timestamps
    end
  end
end
