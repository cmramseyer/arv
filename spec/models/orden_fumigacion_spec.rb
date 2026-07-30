require 'rails_helper'

RSpec.describe OrdenFumigacion, type: :model do
  it { should belong_to(:cultivo).optional }
  it { should belong_to(:estancia).required }

  describe "lotes" do
    it "allows manual lotes" do
      orden = build(:orden_fumigacion, estancia: create(:estancia), lotes: [])
      orden.lote_ordenes_fumigacion.build(nombre_manual: "Lote manual", hectareas_reales: 12.5)

      expect(orden).to be_valid
    end

    it "requires persisted lotes to belong to the orden estancia" do
      orden = build(:orden_fumigacion, estancia: create(:estancia), lotes: [])
      orden.lote_ordenes_fumigacion.build(lote: create(:lote))

      expect(orden).to be_invalid
      expect(orden.errors["lote_ordenes_fumigacion.lote"]).to include("debe pertenecer a la estancia de la orden.")
    end
  end
end
