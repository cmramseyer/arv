require "rails_helper"

RSpec.describe TelegramConversation do
  it "reuses the OpenAI conversation within fifteen minutes" do
    conversation = described_class.for_message(chat_id: 1, user_id: 2, now: Time.zone.parse("2026-08-30 10:00:00"))
    conversation.update!(openai_conversation_id: "conv_123")

    same_conversation = described_class.for_message(chat_id: 1, user_id: 2, now: Time.zone.parse("2026-08-30 10:14:59"))

    expect(same_conversation).to have_attributes(id: conversation.id, openai_conversation_id: "conv_123")
  end

  it "starts a new OpenAI conversation after fifteen minutes of inactivity" do
    conversation = described_class.for_message(chat_id: 1, user_id: 2, now: Time.zone.parse("2026-08-30 10:00:00"))
    conversation.update!(openai_conversation_id: "conv_123")

    same_conversation = described_class.for_message(chat_id: 1, user_id: 2, now: Time.zone.parse("2026-08-30 10:15:01"))

    expect(same_conversation).to have_attributes(id: conversation.id, openai_conversation_id: nil)
  end
end
