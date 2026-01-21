class DosisController < ApplicationController
  before_action :set_dosis, only: %i[ show update destroy ]

  # GET /dosis
  def index
    @dosis = Dosis.all

    render json: @dosis
  end

  # GET /dosis/1
  def show
    render json: @dosis
  end

  # POST /dosis
  def create
    @dosis = Dosis.new(dosis_params)

    if @dosis.save
      render json: @dosis, status: :created, location: @dosis
    else
      render json: @dosis.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dosis/1
  def update
    if @dosis.update(dosis_params)
      render json: @dosis
    else
      render json: @dosis.errors, status: :unprocessable_entity
    end
  end

  # DELETE /dosis/1
  def destroy
    @dosis.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dosis
      @dosis = Dosis.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def dosis_params
      params.expect(dosis: [ :producto_id, :lote_orden_fumigacion_id, :cantidad ])
    end
end
