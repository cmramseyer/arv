class VoiceCommand < ApplicationRecord
  enum :status, { received: 0, transcribing: 1, interpreting: 2, awaiting_confirmation: 3, creating: 4, completed: 5, cancelled: 6, failed: 7 }

  validates :telegram_update_id, :telegram_chat_id, :telegram_user_id, :telegram_message_id, :telegram_file_id, presence: true
  validates :telegram_update_id, uniqueness: true
end
