FactoryBot.define do
  factory :orden_fumigacion do
    lote { create(:lote) }
    creado_por { Faker::Name.name }

    trait(:tres_dosis) do
      after(:build) do |orden_fumigacion, evaluator|
        if orden_fumigacion.dosis.empty?
          orden_fumigacion.dosis = build_list(:dosis, 3, orden_fumigacion: orden_fumigacion)
        end
      end
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
