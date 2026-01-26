class ChangeFacturaFechasToDate < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE facturas
      SET fecha_factura = DATE(fecha_factura),
          fecha_pago = DATE(fecha_pago)
    SQL

    change_column :facturas, :fecha_factura, :date
    change_column :facturas, :fecha_pago, :date
  end

  def down
    change_column :facturas, :fecha_factura, :datetime
    change_column :facturas, :fecha_pago, :datetime

    execute <<~SQL
      UPDATE facturas
      SET fecha_factura = DATETIME(fecha_factura),
          fecha_pago = DATETIME(fecha_pago)
    SQL
  end
end
