FactoryBot.define do
  factory :orden_fumigacion do
    estancia { create(:estancia) }
    lotes { [ create(:lote, estancia: estancia) ] }
    creator { create(:user) }
    cultivo { create(:cultivo) }
    sensible { false }
    comentarios { "Observaciones" }

    after(:build) do |orden|
      orden.estancia = orden.lotes.first.estancia if orden.lotes.any?
    end

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
       maquinista_id { create(:maquinista).id }
    end

    trait(:many_lotes) do
      lotes do
        [ create(:lote, estancia: estancia), create(:lote, estancia: estancia) ]
      end
    end
  end
end
