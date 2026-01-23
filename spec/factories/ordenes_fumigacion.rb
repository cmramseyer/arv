FactoryBot.define do
  factory :orden_fumigacion do
    lotes { [ create(:lote) ] }
    creator { create(:user) }
    cultivo { create(:cultivo) }
    sensible { false }
    comentarios { "Observaciones" }

    # after(:build) do |orden|
    #   orden.lotes << build(:lote) if orden.lotes.empty?
    # end

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
      lotes { [ create(:lote), create(:lote) ] }
    end
  end
end
