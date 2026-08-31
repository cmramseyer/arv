require "openai"
require "pathname"

class Ai::Transcriber
  def self.call(path)
    new.call(path)
  end

  def initialize(client: OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY")))
    @client = client
  end

  def call(path)
    @client.audio.transcriptions.create(
      file: Pathname.new(path),
      model: "gpt-transcribe",
      language: "es"
    ).text
  end
end
