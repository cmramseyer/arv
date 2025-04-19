FactoryBot.define do
  factory :orden_fumigacion do
    lote { create(:lote) }
    creado_por { Faker::Name.name }

    transient do
      dosis_count { 3 }
    end

    after(:build) do |orden_fumigacion, evaluator|
      orden_fumigacion.dosis = build_list(:dosis, evaluator.dosis_count, orden_fumigacion: orden_fumigacion)
    end

    trait(:activa) do
      estado_orden { 'activa' }
    end

    trait(:terminada) do
      estado_orden { 'terminada' }
      info_trabajo { Faker::Lorem.words(number: 20).join(" ") }
      fecha_trabajo { Date.today }
      maquinista { Faker::Name.name }
    end
  end
end
