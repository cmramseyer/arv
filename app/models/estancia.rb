class Estancia < ApplicationRecord
  validates :nombre, presence: true
end
