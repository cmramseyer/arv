class TelegramWebhooksController < ActionController::API
  before_action :verify_secret!

  def create
    message = params.require(:message)
    voice = message[:voice]
    text = message[:text]
    return head :ok unless voice || text.present?

    conversation = TelegramConversation.for_message(
      chat_id: message.dig(:chat, :id),
      user_id: message.dig(:from, :id)
    )

    command = VoiceCommand.create_or_find_by!(telegram_update_id: params.require(:update_id)) do |record|
      record.telegram_conversation = conversation
      record.telegram_chat_id = message.dig(:chat, :id)
      record.telegram_user_id = message.dig(:from, :id)
      record.telegram_message_id = message[:message_id]
      record.input_type = voice ? :voice : :text
      record.telegram_file_id = voice.fetch(:file_id) if voice
      record.input_text = text if text.present?
    end

    ProcessVoiceCommandJob.perform_later(command.id) if command.previously_new_record?

    head :ok
  end

  private
    def verify_secret!
      token = request.headers["X-Telegram-Bot-Api-Secret-Token"]
      expected_token = ENV.fetch("TELEGRAM_WEBHOOK_SECRET")

      return if token.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected_token)

      head :unauthorized
    end
end
