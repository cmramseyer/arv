class TelegramWebhooksController < ActionController::API
  before_action :verify_secret!

  def create
    voice = params.dig(:message, :voice)
    return head :ok unless voice

    command = VoiceCommand.create_or_find_by!(telegram_update_id: params.require(:update_id)) do |record|
      record.telegram_chat_id = params.dig(:message, :chat, :id)
      record.telegram_user_id = params.dig(:message, :from, :id)
      record.telegram_message_id = params.dig(:message, :message_id)
      record.telegram_file_id = voice.fetch(:file_id)
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
