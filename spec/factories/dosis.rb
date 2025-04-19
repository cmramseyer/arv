FactoryBot.define do
  factory :dosis do
    producto { create(:producto) }
    orden_fumigacion { create(:orden_fumigacion) }
    cantidad { rand(1..100) }
  end
end
