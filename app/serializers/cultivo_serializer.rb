class CultivoSerializer
  def initialize(cultivo)
    @cultivo = cultivo
  end

  def show
    {
      id: @cultivo.id,
      nombre: @cultivo.nombre
    }
  end
end
