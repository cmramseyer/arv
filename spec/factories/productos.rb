FactoryBot.define do
  factory :producto do
    nombre { Faker::Agro.producto }
    tipo_producto { 'agroquimico' }
    unidad_medida { Producto.unidad_medidas.values.sample }
  end
end
