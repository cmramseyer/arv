class Estancia < ApplicationRecord
  validates :nombre, presence: true
  has_many :lotes
end
