class ReplaceCreadoPorWithCreatorIdInOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    remove_column :ordenes_fumigacion, :creado_por, :string
    add_reference :ordenes_fumigacion, :creator, foreign_key: { to_table: :users }, null: false
  end
end
