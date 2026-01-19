FactoryBot.define do
  factory :facturas_ordenes_fumigacion do
    factura
    orden_fumigacion
    importe { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    nro_orden_cliente { nil }
  end
end
