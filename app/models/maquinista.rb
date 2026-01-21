class Maquinista < ApplicationRecord
  self.table_name = "maquinistas"
  validates :nombre, presence: true, uniqueness: true
end
