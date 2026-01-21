class MaquinistaSerializer
  def initialize(maquinista)
    @maquinista = maquinista
  end

  def show
    {
      id: @maquinista.id,
      nombre: @maquinista.nombre
    }
  end
end
