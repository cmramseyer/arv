FactoryBot.define do
  factory :lote do
    estancia { create(:estancia) }
    nombre { Faker::Name.name }
    lat { Faker::Address.latitude }
    long { Faker::Address.longitude }
    hectareas { rand(10.00..99.99).round(2) }
  end
end
