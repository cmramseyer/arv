require "rails_helper"

RSpec.describe ProcessVoiceCommandJob do
  it "downloads, transcribes, and replies to the voice message" do
    conversation = TelegramConversation.create!(telegram_chat_id: 202, telegram_user_id: 303)
    command = VoiceCommand.create!(
      telegram_update_id: 101,
      telegram_chat_id: 202,
      telegram_user_id: 303,
      telegram_message_id: 404,
      telegram_file_id: "voice-file-id",
      telegram_conversation: conversation
    )
    client = instance_double(Telegram::Client)
    allow(Telegram::Client).to receive(:new).and_return(client)
    allow(client).to receive(:get_file).with(file_id: "voice-file-id").and_return(
      "file_path" => "voice.ogg",
      "file_size" => 100
    )
    allow(client).to receive(:download_file) do |file_path:, destination:|
      expect(file_path).to eq("voice.ogg")
      destination.write("audio")
    end
    downloaded_path = nil
    allow(Ai::Transcriber).to receive(:call) do |path|
      downloaded_path = path
      "Aplicar producto en lote norte"
    end
    allow(Ai::OrderInterpreter).to receive(:call).with(
      input: "Aplicar producto en lote norte",
      request_id: "voice-command-#{command.id}",
      conversation_id: nil
    ).and_return(Ai::OrderInterpreter::Result.new(text: "Orden creada.", conversation_id: "conv_123"))

    expect(client).to receive(:send_message).with(chat_id: 202, text: "Audio recibido.").ordered
    expect(client).to receive(:send_message).with(
      chat_id: 202,
      text: "Transcripcion:\nAplicar producto en lote norte"
    ).ordered
    expect(client).to receive(:send_message).with(
      chat_id: 202,
      text: "Orden creada."
    ).ordered

    described_class.perform_now(command.id)

    command.reload
    expect(command).to have_attributes(
      status: "completed",
      transcript: "Aplicar producto en lote norte",
      error: nil
    )
    expect(File.extname(downloaded_path)).to eq(".ogg")
    expect(File.exist?(downloaded_path)).to be(false)
    expect(conversation.reload.openai_conversation_id).to eq("conv_123")
  end

  it "continues a text message in the existing conversation" do
    conversation = TelegramConversation.create!(
      telegram_chat_id: 202,
      telegram_user_id: 303,
      openai_conversation_id: "conv_123"
    )
    command = VoiceCommand.create!(
      telegram_update_id: 101,
      telegram_chat_id: 202,
      telegram_user_id: 303,
      telegram_message_id: 404,
      telegram_conversation: conversation,
      input_type: :text,
      input_text: "El lote es siete"
    )
    client = instance_double(Telegram::Client)
    allow(Telegram::Client).to receive(:new).and_return(client)
    allow(Ai::OrderInterpreter).to receive(:call).with(
      input: "El lote es siete",
      request_id: "voice-command-#{command.id}",
      conversation_id: "conv_123"
    ).and_return(Ai::OrderInterpreter::Result.new(text: "Orden creada.", conversation_id: "conv_123"))

    expect(client).to receive(:send_message).with(chat_id: 202, text: "Orden creada.")

    described_class.perform_now(command.id)

    expect(command.reload.status).to eq("completed")
  end

  it "closes the conversation after the command creates an order" do
    conversation = TelegramConversation.create!(
      telegram_chat_id: 202,
      telegram_user_id: 303,
      openai_conversation_id: "conv_123"
    )
    command = VoiceCommand.create!(
      telegram_update_id: 101,
      telegram_chat_id: 202,
      telegram_user_id: 303,
      telegram_message_id: 404,
      telegram_conversation: conversation,
      input_type: :text,
      input_text: "Crea la orden"
    )
    estancia = create(:estancia)
    lote = create(:lote, estancia: estancia)
    producto = create(:producto)
    Orders::Create.call(
      request_id: "voice-command-#{command.id}",
      estancia_id: estancia.id,
      lote_id: lote.id,
      producto_id: producto.id,
      cantidad: 20,
      creator: create(:user)
    )
    client = instance_double(Telegram::Client)
    allow(Telegram::Client).to receive(:new).and_return(client)
    allow(Ai::OrderInterpreter).to receive(:call).and_return(
      Ai::OrderInterpreter::Result.new(text: "Orden creada.", conversation_id: "conv_123")
    )
    allow(client).to receive(:send_message)

    described_class.perform_now(command.id)

    expect(conversation.reload.openai_conversation_id).to be_nil
  end

  it "marks the command as failed when transcription fails" do
    conversation = TelegramConversation.create!(telegram_chat_id: 202, telegram_user_id: 303)
    command = VoiceCommand.create!(
      telegram_update_id: 101,
      telegram_chat_id: 202,
      telegram_user_id: 303,
      telegram_message_id: 404,
      telegram_file_id: "voice-file-id",
      telegram_conversation: conversation
    )
    client = instance_double(Telegram::Client)
    allow(Telegram::Client).to receive(:new).and_return(client)
    allow(client).to receive(:get_file).with(file_id: "voice-file-id").and_return(
      "file_path" => "voice.ogg",
      "file_size" => 100
    )
    allow(client).to receive(:download_file) { |file_path:, destination:| destination.write("audio") }
    allow(Ai::Transcriber).to receive(:call).and_raise("OpenAI unavailable")

    expect(client).to receive(:send_message).with(chat_id: 202, text: "Audio recibido.").ordered
    expect(client).to receive(:send_message).with(
      chat_id: 202,
      text: "No pudimos procesar el audio. Intenta de nuevo."
    ).ordered

    described_class.perform_now(command.id)

    command.reload
    expect(command).to have_attributes(status: "failed", error: "OpenAI unavailable")
  end
end
