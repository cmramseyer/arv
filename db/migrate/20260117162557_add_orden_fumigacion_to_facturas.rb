class AddOrdenFumigacionToFacturas < ActiveRecord::Migration[8.0]
  def up
    return unless column_exists?(:facturas, :orden_fumigacion_id)

    remove_reference :facturas, :orden_fumigacion, foreign_key: true
  end

  def down
    return if column_exists?(:facturas, :orden_fumigacion_id)

    add_reference :facturas, :orden_fumigacion, null: false, foreign_key: true
  end
end
