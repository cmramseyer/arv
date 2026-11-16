namespace :estancias do
  desc "Lista las estancias cuyo telefono no tiene exactamente 10 dígitos"
  task listar_telefonos_invalidos: :environment do
    Estancia.telefonos_invalidos.each do |estancia|
      puts "#{estancia.id}\t#{estancia.nombre}\t#{estancia.telefono}"
    end
  end
end
