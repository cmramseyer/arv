class ProcessVoiceCommandJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  def perform(voice_command_id)
    command = VoiceCommand.find(voice_command_id)

    Telegram::Client.new.send_message(
      chat_id: command.telegram_chat_id,
      text: "Audio recibido."
    )
  end
end
