class LotesController < ApplicationController
  before_action :set_lote, only: %i[ show update destroy ]

  # GET /lotes
  def index
    @lotes = Lote.all

    render json: @lotes
  end

  # GET /lotes/1
  def show
    render json: @lote
  end

  # POST /lotes
  def create
    @lote = Lote.new(lote_params)

    if @lote.save
      render json: @lote, status: :created, location: @lote
    else
      render json: @lote.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lotes/1
  def update
    if @lote.update(lote_params)
      render json: @lote
    else
      render json: @lote.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lotes/1
  def destroy
    @lote.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lote
      @lote = Lote.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def lote_params
      params.expect(lote: [ :nombre, :lat, :long, :link_mapa, :hectareas, :estancia_id ])
    end
end
