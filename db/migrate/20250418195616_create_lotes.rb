class CreateLotes < ActiveRecord::Migration[8.0]
  def change
    create_table :lotes do |t|
      t.string :nombre
      t.decimal :lat, precision: 10, scale: 8
      t.decimal :long, precision: 10, scale: 8
      t.string :link_mapa
      t.decimal :hectareas, precision: 10, scale: 2
      t.references :estancia, null: false, foreign_key: true

      t.timestamps
    end
  end
end
