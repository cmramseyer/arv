class RenameTipoMedidaToUnidadMedida < ActiveRecord::Migration[8.0]
  def change
    rename_column :productos, :tipo_medida, :unidad_medida
  end
end
