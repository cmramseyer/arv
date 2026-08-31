require "rails_helper"

RSpec.describe Telegram::AllowedUserIds do
  around do |example|
    original_ids = ENV.fetch("TELEGRAM_ALLOWED_USER_IDS", nil)
    example.run
  ensure
    ENV["TELEGRAM_ALLOWED_USER_IDS"] = original_ids
  end

  it "matches numeric IDs from a comma-separated environment variable" do
    ENV["TELEGRAM_ALLOWED_USER_IDS"] = " 123,456 , 789 "

    expect(described_class).to be_include(456)
    expect(described_class).to be_include("789")
    expect(described_class).not_to be_include(111)
  end

  it "denies every user when the environment variable is absent" do
    ENV.delete("TELEGRAM_ALLOWED_USER_IDS")

    expect(described_class).not_to be_include(123)
  end
end
