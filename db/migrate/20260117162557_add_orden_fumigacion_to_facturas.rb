class AddOrdenFumigacionToFacturas < ActiveRecord::Migration[8.0]
  def up
    return if column_exists?(:facturas, :orden_fumigacion_id)

    add_reference :facturas, :orden_fumigacion, null: false, foreign_key: true
  end

  def down
    remove_reference :facturas, :orden_fumigacion, foreign_key: true if column_exists?(:facturas, :orden_fumigacion_id)
  end
end
