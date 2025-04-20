FactoryBot.define do
  factory :dosis do
    producto { create(:producto) }
    cantidad { rand(1..100) }

    orden_fumigacion { nil }

    after(:build) do |dosis|
      dosis.orden_fumigacion ||= build(:orden_fumigacion, dosis_count: 0)
      dosis.orden_fumigacion.dosis << dosis unless dosis.orden_fumigacion.dosis.include?(dosis)
    end
  end
end
