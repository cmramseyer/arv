require "rails_helper"
require "tempfile"

RSpec.describe Ai::Transcriber do
  it "submits the audio file to OpenAI's transcription endpoint" do
    response = double(text: "Aplicar en lote norte")
    transcriptions = double
    audio = double(transcriptions: transcriptions)
    client = double(audio: audio)

    Tempfile.create([ "voice", ".ogg" ]) do |file|
      expect(transcriptions).to receive(:create).with(
        file: Pathname.new(file.path),
        model: "gpt-transcribe",
        language: "es"
      ).and_return(response)

      transcript = described_class.new(client: client).call(file.path)

      expect(transcript).to eq("Aplicar en lote norte")
    end
  end
end
