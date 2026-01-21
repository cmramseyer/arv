class MaquinistasController < ApplicationController
  before_action :set_maquinista, only: %i[ show update destroy ]

  # GET /maquinistas
  def index
    @maquinistas = Maquinista.all

    render json: @maquinistas
  end

  # GET /maquinistas/1
  def show
    render json: @maquinista
  end

  # POST /maquinistas
  def create
    @maquinista = Maquinista.new(maquinista_params)

    if @maquinista.save
      render json: @maquinista, status: :created, location: @maquinista
    else
      render json: @maquinista.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /maquinistas/1
  def update
    if @maquinista.update(maquinista_params)
      render json: @maquinista
    else
      render json: @maquinista.errors, status: :unprocessable_entity
    end
  end

  # DELETE /maquinistas/1
  def destroy
    @maquinista.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_maquinista
      @maquinista = Maquinista.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def maquinista_params
      params.expect(maquinista: [ :nombre ])
    end
end
