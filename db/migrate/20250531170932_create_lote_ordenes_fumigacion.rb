class CreateLoteOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    create_table :lote_ordenes_fumigacion do |t|
      t.references :lote, null: false, foreign_key: true
      t.references :orden_fumigacion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
