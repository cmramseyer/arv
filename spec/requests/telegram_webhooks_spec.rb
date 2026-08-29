require "rails_helper"

RSpec.describe "Telegram webhooks", type: :request do
  include ActiveJob::TestHelper

  let(:webhook_secret) { "test-telegram-secret" }
  let(:headers) { { "X-Telegram-Bot-Api-Secret-Token" => webhook_secret } }

  around do |example|
    original_secret = ENV.fetch("TELEGRAM_WEBHOOK_SECRET", nil)
    original_adapter = ActiveJob::Base.queue_adapter
    ENV["TELEGRAM_WEBHOOK_SECRET"] = webhook_secret
    ActiveJob::Base.queue_adapter = :test
    example.run
  ensure
    ENV["TELEGRAM_WEBHOOK_SECRET"] = original_secret
    ActiveJob::Base.queue_adapter = original_adapter
  end

  before { clear_enqueued_jobs }
  after { clear_enqueued_jobs }

  it "persists a voice command and enqueues its processing" do
    expect do
      post "/telegram/webhook", params: voice_update, headers: headers, as: :json
    end.to change(VoiceCommand, :count).by(1)

    command = VoiceCommand.last

    expect(response).to have_http_status(:ok)
    expect(command).to have_attributes(
      telegram_update_id: 101,
      telegram_chat_id: 202,
      telegram_user_id: 303,
      telegram_message_id: 404,
      telegram_file_id: "voice-file-id",
      status: "received"
    )
    expect(ProcessVoiceCommandJob).to have_been_enqueued.with(command.id)
  end

  it "does not process a Telegram update twice" do
    post "/telegram/webhook", params: voice_update, headers: headers, as: :json

    expect do
      post "/telegram/webhook", params: voice_update, headers: headers, as: :json
    end.not_to change(VoiceCommand, :count)

    expect(enqueued_jobs.count { |job| job[:job] == ProcessVoiceCommandJob }).to eq(1)
  end

  it "rejects a request without the Telegram secret" do
    post "/telegram/webhook", params: voice_update, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(VoiceCommand.count).to eq(0)
  end

  it "ignores non-voice updates" do
    post "/telegram/webhook", params: text_update, headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(VoiceCommand.count).to eq(0)
    expect(enqueued_jobs).to be_empty
  end

  private
    def voice_update
      {
        update_id: 101,
        message: {
          message_id: 404,
          from: { id: 303 },
          chat: { id: 202 },
          voice: { file_id: "voice-file-id" }
        }
      }
    end

    def text_update
      {
        update_id: 102,
        message: {
          message_id: 405,
          from: { id: 303 },
          chat: { id: 202 },
          text: "Hola"
        }
      }
    end
end
