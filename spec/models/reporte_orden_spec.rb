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
    it "returns none when attachment_ids is nil" do
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

      expect(reporte.adjuntos_para_pdf(lote, orden).map(&:id)).to match_array(selected_ids)
    end

    it "returns intersection between available ids and attachment_ids" do
      orden.adjuntos.attach(
        io: File.open(file_path),
        filename: "orden_adjunto.png",
        content_type: "image/png"
      )
      orden_adjunto_id = orden.adjuntos.first.id
      selected_ids = [ lote.adjuntos.first.id, orden_adjunto_id, 999_999 ]
      reporte = described_class.new(pdf, orden, attachment_ids: selected_ids)

      expect(reporte.selected_attachment_ids_for_pdf(lote, orden)).to match_array([ lote.adjuntos.first.id, orden_adjunto_id ])
    end
  end

  describe "#adjuntos_orden_para_pdf" do
    it "returns only orden adjuntos that intersect with attachment_ids" do
      orden.adjuntos.attach(
        io: File.open(file_path),
        filename: "orden_adjunto_uno.png",
        content_type: "image/png"
      )
      orden.adjuntos.attach(
        io: File.open(file_path),
        filename: "orden_adjunto_dos.png",
        content_type: "image/png"
      )
      selected_order_adjunto_id = orden.adjuntos.first.id

      reporte = described_class.new(pdf, orden, attachment_ids: [ lote.adjuntos.first.id, selected_order_adjunto_id ])

      expect(reporte.adjuntos_orden_para_pdf(orden).map(&:id)).to match_array([ selected_order_adjunto_id ])
    end

    it "returns none when attachment_ids are blank" do
      orden.adjuntos.attach(
        io: File.open(file_path),
        filename: "orden_adjunto.png",
        content_type: "image/png"
      )
      reporte = described_class.new(pdf, orden, attachment_ids: [])

      expect(reporte.adjuntos_orden_para_pdf).to be_empty
    end
  end
end
