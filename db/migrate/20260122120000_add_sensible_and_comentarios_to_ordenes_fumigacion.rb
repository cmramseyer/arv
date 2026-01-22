class AddSensibleAndComentariosToOrdenesFumigacion < ActiveRecord::Migration[8.0]
  def change
    add_column :ordenes_fumigacion, :sensible, :boolean, default: false
    add_column :ordenes_fumigacion, :comentarios, :text
  end
end
