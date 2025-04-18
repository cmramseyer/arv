class EstanciasController < ApplicationController
  before_action :set_estancia, only: %i[ show update destroy ]

  # GET /estancias
  def index
    @estancias = Estancia.all

    render json: @estancias
  end

  # GET /estancias/1
  def show
    render json: @estancia
  end

  # POST /estancias
  def create
    @estancia = Estancia.new(estancia_params)

    if @estancia.save
      render json: @estancia, status: :created, location: @estancia
    else
      render json: @estancia.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /estancias/1
  def update
    if @estancia.update(estancia_params)
      render json: @estancia
    else
      render json: @estancia.errors, status: :unprocessable_entity
    end
  end

  # DELETE /estancias/1
  def destroy
    @estancia.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_estancia
      @estancia = Estancia.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def estancia_params
      params.expect(estancia: [ :nombre, :contacto, :telefono, :email ])
    end
end
