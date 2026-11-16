require 'rails_helper'
require 'rake'

RSpec.describe 'estancias:listar_telefonos_invalidos' do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?('estancias:listar_telefonos_invalidos')
  end

  after do
    Rake::Task['estancias:listar_telefonos_invalidos'].reenable
  end

  it 'imprime id, nombre y telefono de cada estancia con telefono invalido' do
    invalida = create(:estancia, nombre: 'Campo Roto', telefono: '1123456789')
    invalida.update_column(:telefono, '123')
    create(:estancia, nombre: 'Campo Sano', telefono: '1123456789')
    create(:estancia, nombre: 'Campo Sin Telefono', telefono: nil)

    expect { Rake::Task['estancias:listar_telefonos_invalidos'].invoke }
      .to output(/\A#{invalida.id}\tCampo Roto\t123\n\z/).to_stdout
  end

  it 'no imprime nada cuando no hay telefonos invalidos' do
    create(:estancia, nombre: 'Campo Sano', telefono: '1123456789')

    expect { Rake::Task['estancias:listar_telefonos_invalidos'].invoke }
      .to output("").to_stdout
  end
end
