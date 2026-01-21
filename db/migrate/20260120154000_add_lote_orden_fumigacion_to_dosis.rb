class AddLoteOrdenFumigacionToDosis < ActiveRecord::Migration[8.0]
  def change
    add_reference :dosis, :lote_orden_fumigacion, foreign_key: true
    remove_reference :dosis, :orden_fumigacion, foreign_key: true
  end
end
