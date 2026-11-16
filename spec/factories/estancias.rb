FactoryBot.define do
  factory :estancia do
    nombre { Faker::Company.name }
    contacto { Faker::Name.name }
    telefono { Faker::Number.number(digits: 10).to_s }
    email { Faker::Internet.email }
  end
end
