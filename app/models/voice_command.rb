class VoiceCommand < ApplicationRecord
  enum :status, { received: 0, transcribing: 1, interpreting: 2, awaiting_confirmation: 3, creating: 4, completed: 5, cancelled: 6, failed: 7 }
  enum :input_type, { voice: 0, text: 1 }

  belongs_to :telegram_conversation, optional: true

  validates :telegram_update_id, :telegram_chat_id, :telegram_user_id, :telegram_message_id, presence: true
  validates :telegram_file_id, presence: true, if: :voice?
  validates :input_text, presence: true, if: :text?
  validates :telegram_update_id, uniqueness: true
end
