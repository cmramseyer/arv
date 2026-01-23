class AddHectareasRealesToLoteOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    add_column :lote_ordenes_fumigacion, :hectareas_reales, :decimal, precision: 10, scale: 2
  end
end
