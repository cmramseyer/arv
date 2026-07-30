class AddEstanciaAndManualLotesToOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def up
    add_reference :ordenes_fumigacion, :estancia, null: true, foreign_key: true

    execute <<~SQL.squish
      UPDATE ordenes_fumigacion
      SET estancia_id = (
        SELECT lotes.estancia_id
        FROM lote_ordenes_fumigacion
        INNER JOIN lotes ON lotes.id = lote_ordenes_fumigacion.lote_id
        WHERE lote_ordenes_fumigacion.orden_fumigacion_id = ordenes_fumigacion.id
        LIMIT 1
      )
    SQL

    change_column_null :ordenes_fumigacion, :estancia_id, false
    change_column_null :lote_ordenes_fumigacion, :lote_id, true
    add_column :lote_ordenes_fumigacion, :nombre_manual, :string
  end

  def down
    remove_column :lote_ordenes_fumigacion, :nombre_manual
    change_column_null :lote_ordenes_fumigacion, :lote_id, false
    remove_reference :ordenes_fumigacion, :estancia, foreign_key: true
  end
end
