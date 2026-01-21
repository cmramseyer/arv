class RenameMaquinistaToMaquinistaIdInOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    remove_column :ordenes_fumigacion, :maquinista
    add_reference :ordenes_fumigacion, :maquinista, foreign_key: true
  end
end
