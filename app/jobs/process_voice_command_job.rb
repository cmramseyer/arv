class ProcessVoiceCommandJob < ApplicationJob
  require "tempfile"

  discard_on ActiveRecord::RecordNotFound

  MAX_FILE_SIZE = 20.megabytes

  def perform(voice_command_id)
    command = VoiceCommand.find(voice_command_id)
    client = Telegram::Client.new

    Rails.logger.info("VoiceCommand #{command.id}: acknowledging Telegram audio")
    client.send_message(
      chat_id: command.telegram_chat_id,
      text: "Audio recibido."
    )

    return unless start_transcription(command)

    Rails.logger.info("VoiceCommand #{command.id}: requesting Telegram file metadata")
    file = client.get_file(file_id: command.telegram_file_id)
    validate_file_size!(file)
    Rails.logger.info(
      "VoiceCommand #{command.id}: downloading #{file.fetch("file_path")} (#{file.fetch("file_size", "unknown")} bytes)"
    )

    Tempfile.create([ "telegram-voice-", ".ogg" ]) do |audio|
      audio.binmode
      client.download_file(file_path: file.fetch("file_path"), destination: audio)

      Rails.logger.info("VoiceCommand #{command.id}: transcribing #{audio.size} downloaded bytes")
      transcript = Ai::Transcriber.call(audio.path)
      command.update!(transcript: transcript, status: :interpreting, error: nil)
      Rails.logger.info("VoiceCommand #{command.id}: transcription completed (#{transcript.length} characters)")

      client.send_message(
        chat_id: command.telegram_chat_id,
        text: "Transcripcion:\n#{transcript}"
      )

      Rails.logger.info("VoiceCommand #{command.id}: interpreting the transcribed instruction")
      response = Ai::OrderInterpreter.call(
        transcript: transcript,
        request_id: "voice-command-#{command.id}"
      )
      command.update!(status: :completed)
      Rails.logger.info("VoiceCommand #{command.id}: instruction interpretation completed")

      client.send_message(chat_id: command.telegram_chat_id, text: response)
    end
  rescue ActiveRecord::RecordNotFound
    raise
  rescue StandardError => error
    Rails.logger.error("VoiceCommand #{command&.id}: voice processing failed: #{error.class}: #{error.message}")
    Rails.logger.error("VoiceCommand #{command&.id}: OpenAI error response: #{error.body.inspect}") if error.respond_to?(:body)
    Rails.logger.error(error.backtrace.join("\n"))
    command&.update!(status: :failed, error: error.message)
    client&.send_message(
      chat_id: command.telegram_chat_id,
      text: "No pudimos procesar el audio. Intenta de nuevo."
    )
  end

  private

    def start_transcription(command)
      command.with_lock do
        next false unless command.received?

        command.transcribing!
      end
    end

    def validate_file_size!(file)
      return if file.fetch("file_size", 0) <= MAX_FILE_SIZE

      raise "Telegram voice message exceeds the #{MAX_FILE_SIZE} byte limit"
    end
end
