class CreateEstancias < ActiveRecord::Migration[8.0]
  def change
    create_table :estancias do |t|
      t.string :nombre
      t.string :contacto
      t.string :telefono
      t.string :email

      t.timestamps
    end
  end
end
