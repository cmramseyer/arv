class AddTempColumnsInOrdenFumigacion < ActiveRecord::Migration[8.0]
  def change
    add_column :ordenes_fumigacion, :temp_lotes, :string
    add_column :ordenes_fumigacion, :temp_hectareas, :float
  end
end
