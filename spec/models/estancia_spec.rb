require 'rails_helper'

RSpec.describe Estancia, type: :model do
  describe 'validaciones' do
    it 'es válida con atributos válidos' do
      expect(build(:estancia)).to be_valid
    end

    it 'no es válida sin nombre' do
      estancia = build(:estancia, nombre: nil)
      expect(estancia).not_to be_valid
      expect(estancia.errors[:nombre]).to include("can't be blank")
    end
  end

  describe 'telefono' do
    it 'es válida con exactamente 10 dígitos' do
      expect(build(:estancia, telefono: '1123456789')).to be_valid
    end

    it 'no es válida con menos de 10 dígitos' do
      estancia = build(:estancia, telefono: '112345678')

      expect(estancia).not_to be_valid
      expect(estancia.errors[:telefono]).to be_present
    end

    it 'no es válida con más de 10 dígitos' do
      estancia = build(:estancia, telefono: '11234567890')

      expect(estancia).not_to be_valid
      expect(estancia.errors[:telefono]).to be_present
    end

    it 'no es válida con caracteres que no son dígitos' do
      estancia = build(:estancia, telefono: '112-345678')

      expect(estancia).not_to be_valid
      expect(estancia.errors[:telefono]).to be_present
    end

    it 'es válida sin teléfono' do
      expect(build(:estancia, telefono: nil)).to be_valid
    end

    it 'es válida con teléfono en blanco' do
      expect(build(:estancia, telefono: '')).to be_valid
    end

    it 'no guarda una actualización con un teléfono inválido' do
      estancia = create(:estancia)
      estancia.assign_attributes(telefono: '123')

      expect(estancia.save).to be(false)
      expect(estancia.reload.telefono).not_to eq('123')
    end

    it 'guarda una actualización con el teléfono en blanco' do
      estancia = create(:estancia)

      expect(estancia.update(telefono: '')).to be(true)
      expect(estancia.reload.telefono).to eq('')
    end
  end

  describe '.telefonos_invalidos' do
    it 'incluye solo los teléfonos presentes que no tienen 10 dígitos' do
      valida = create(:estancia, telefono: '1123456789')
      sin_telefono = create(:estancia, telefono: nil)
      en_blanco = create(:estancia, telefono: '')
      con_espacios = create(:estancia, telefono: '1123456789')
      con_espacios.update_column(:telefono, '   ')
      invalida = create(:estancia, telefono: '1123456789')
      invalida.update_column(:telefono, '123')

      expect(described_class.telefonos_invalidos.map(&:id)).to eq([ invalida.id ])
    end
  end

  describe 'asociaciones' do
    it { is_expected.to have_many(:lotes) }
  end
end
