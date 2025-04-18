class CreateProductos < ActiveRecord::Migration[8.0]
  def change
    create_table :productos do |t|
      t.string :nombre
      t.string :tipo
      t.integer :tipo_medida, default: 0, null: false

      t.timestamps
    end
  end
end
