class TelegramConversation < ApplicationRecord
  SESSION_TIMEOUT = 15.minutes

  has_many :voice_commands, dependent: :nullify

  validates :telegram_chat_id, :telegram_user_id, presence: true
  validates :telegram_user_id, uniqueness: { scope: :telegram_chat_id }

  def self.for_message(chat_id:, user_id:, now: Time.current)
    conversation = find_or_create_by!(telegram_chat_id: chat_id, telegram_user_id: user_id)

    conversation.with_lock do
      conversation.update!(
        openai_conversation_id: conversation.expired_at?(now) ? nil : conversation.openai_conversation_id,
        last_message_at: now
      )
    end

    conversation
  end

  def expired_at?(time)
    last_message_at.present? && last_message_at < time - SESSION_TIMEOUT
  end

  def close!
    update!(openai_conversation_id: nil)
  end
end
