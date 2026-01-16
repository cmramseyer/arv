FactoryBot.define do
  factory :orden_facturada do
    orden_fumigacion { create(:orden_fumigacion, :terminada) }
    fecha_factura { Time.zone.now }
    fecha_pago { nil }
  end
end
