require "rails_helper"

RSpec.describe ProcessVoiceCommandJob do
  it "acknowledges the voice message in Telegram" do
    command = VoiceCommand.create!(
      telegram_update_id: 101,
      telegram_chat_id: 202,
      telegram_user_id: 303,
      telegram_message_id: 404,
      telegram_file_id: "voice-file-id"
    )
    client = instance_double(Telegram::Client)
    allow(Telegram::Client).to receive(:new).and_return(client)

    expect(client).to receive(:send_message).with(chat_id: 202, text: "Audio recibido.")

    described_class.perform_now(command.id)
  end
end
