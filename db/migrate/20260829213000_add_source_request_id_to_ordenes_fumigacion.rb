class AddSourceRequestIdToOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    add_column :ordenes_fumigacion, :source_request_id, :string
    add_index :ordenes_fumigacion, :source_request_id, unique: true
  end
end
