FactoryBot.define do
  factory :factura do
    orden_fumigacion { create(:orden_fumigacion, :terminada) }
    fecha_factura { Time.zone.now }
    fecha_pago { nil }
  end
end
