class RemoveTempFieldsFromOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    remove_column :ordenes_fumigacion, :temp_lotes, :string
    remove_column :ordenes_fumigacion, :temp_hectareas, :float
  end
end
