class ProcessVoiceCommandJob < ApplicationJob
  require "tempfile"

  discard_on ActiveRecord::RecordNotFound

  MAX_FILE_SIZE = 20.megabytes

  def perform(voice_command_id)
    command = VoiceCommand.find(voice_command_id)
    client = Telegram::Client.new

    return unless start_processing(command)

    input = command.voice? ? transcribe(command, client) : command.input_text
    response = interpret(command, input)
    command.update!(status: :completed)
    Rails.logger.info("VoiceCommand #{command.id}: instruction interpretation completed")

    client.send_message(chat_id: command.telegram_chat_id, text: response.text)
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

    def start_processing(command)
      command.with_lock do
        next false unless command.received?

        command.voice? ? command.transcribing! : command.interpreting!
      end
    end

    def transcribe(command, client)
      Rails.logger.info("VoiceCommand #{command.id}: acknowledging Telegram audio")
      client.send_message(chat_id: command.telegram_chat_id, text: "Audio recibido.")

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
        client.send_message(chat_id: command.telegram_chat_id, text: "Transcripcion:\n#{transcript}")
        transcript
      end
    end

    def interpret(command, input)
      conversation = command.telegram_conversation || TelegramConversation.for_message(
        chat_id: command.telegram_chat_id,
        user_id: command.telegram_user_id
      )
      command.update!(telegram_conversation: conversation) unless command.telegram_conversation

      Rails.logger.info("VoiceCommand #{command.id}: interpreting the user instruction")
      response = Ai::OrderInterpreter.call(
        input: input,
        request_id: "voice-command-#{command.id}",
        conversation_id: conversation.openai_conversation_id
      )
      conversation.update!(openai_conversation_id: response.conversation_id)
      conversation.close! if OrdenFumigacion.exists?(source_request_id: "voice-command-#{command.id}")
      response
    end

    def validate_file_size!(file)
      return if file.fetch("file_size", 0) <= MAX_FILE_SIZE

      raise "Telegram voice message exceeds the #{MAX_FILE_SIZE} byte limit"
    end
end
