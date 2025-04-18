class CreateDosis < ActiveRecord::Migration[8.0]
  def change
    create_table :dosis do |t|
      t.references :producto, null: false, foreign_key: true
      t.references :orden_fumigacion, null: false, foreign_key: true
      t.integer :cantidad

      t.timestamps
    end
  end
end
