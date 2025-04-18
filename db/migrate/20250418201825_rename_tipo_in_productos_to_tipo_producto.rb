class RenameTipoInProductosToTipoProducto < ActiveRecord::Migration[8.0]
  def change
    rename_column :productos, :tipo, :tipo_producto
  end
end
