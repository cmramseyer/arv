class CreateMaquinistas < ActiveRecord::Migration[8.0]
  def change
    create_table :maquinistas do |t|
      t.string :nombre

      t.timestamps
    end
  end
end
