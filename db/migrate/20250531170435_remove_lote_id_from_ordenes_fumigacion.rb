class RemoveLoteIdFromOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    remove_column :ordenes_fumigacion, :lote_id, :bigint
  end
end
