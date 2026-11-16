class Estancia < ApplicationRecord
  TELEFONO_FORMAT = /\A\d{10}\z/

  validates :nombre, presence: true
  validates :telefono, format: { with: TELEFONO_FORMAT }, allow_blank: true
  has_many :lotes
  has_many :ordenes_fumigacion

  def self.telefonos_invalidos
    where.not(telefono: [ nil, "" ]).order(:id).select do |estancia|
      estancia.telefono.present? && !TELEFONO_FORMAT.match?(estancia.telefono)
    end
  end
end
