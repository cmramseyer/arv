require "rails_helper"

RSpec.describe ReporteOrden do
  let(:pdf) { instance_double(Prawn::Document) }
  let(:lote) { create(:lote) }
  let(:orden) { create(:orden_fumigacion, :activa, lotes: [ lote ]) }
  let(:file_path) { Rails.root.join("spec/fixtures/files/sample_file.png") }

  before do
    3.times do |index|
      lote.adjuntos.attach(
        io: File.open(file_path),
        filename: "adjunto_#{index}.png",
        content_type: "image/png"
      )
    end
  end

  describe "#adjuntos_para_pdf" do
    it "returns all adjuntos when attachment_ids is nil" do
      reporte = described_class.new(pdf, orden)

      expect(reporte.adjuntos_para_pdf(lote)).to be_empty
    end

    it "returns none when attachment_ids is empty" do
      reporte = described_class.new(pdf, orden, attachment_ids: [])

      expect(reporte.adjuntos_para_pdf(lote)).to be_empty
    end

    it "returns only adjuntos in attachment_ids" do
      selected_ids = [ lote.adjuntos.first.id, lote.adjuntos.last.id ]
      reporte = described_class.new(pdf, orden, attachment_ids: selected_ids)

      expect(reporte.adjuntos_para_pdf(lote).map(&:id)).to match_array(selected_ids)
    end
  end
end
