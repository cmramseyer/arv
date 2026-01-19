FactoryBot.define do
  factory :factura do
    fecha_factura { Time.zone.now }
    fecha_pago { nil }
    nro_factura { nil }

    transient do
      ordenes_fumigacion { [ create(:orden_fumigacion, :terminada) ] }
    end

    after(:create) do |factura, evaluator|
      factura.ordenes_fumigacion << evaluator.ordenes_fumigacion
    end
  end
end
