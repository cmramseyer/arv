class Cultivo < ApplicationRecord
  self.table_name = "cultivos"
  validates :nombre, presence: true, uniqueness: true
end
