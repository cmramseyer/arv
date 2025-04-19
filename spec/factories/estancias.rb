FactoryBot.define do
  factory :estancia do
    nombre { Faker::Company.name }
    contacto { Faker::Name.name }
    telefono { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
  end
end
