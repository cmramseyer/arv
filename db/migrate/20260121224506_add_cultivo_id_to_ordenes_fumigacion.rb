class AddCultivoIdToOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    add_reference :ordenes_fumigacion, :cultivo, foreign_key: true
  end
end
