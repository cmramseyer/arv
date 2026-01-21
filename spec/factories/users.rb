FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    username { Faker::Internet.unique.username }
  end
end
