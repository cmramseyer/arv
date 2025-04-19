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

  describe 'asociaciones' do
    it { is_expected.to have_many(:lotes) }
  end
end