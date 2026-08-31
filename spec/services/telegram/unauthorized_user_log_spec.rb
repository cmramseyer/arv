require "rails_helper"
require "tempfile"

RSpec.describe Telegram::UnauthorizedUserLog do
  it "appends a timestamped unauthorized Telegram ID" do
    Tempfile.create("telegram-unauthorized") do |file|
      described_class.call(
        user_id: 123_456_789,
        path: file.path,
        now: Time.find_zone!(OrdenFumigacion::LOCALE_TIME_ZONE).parse("2026-08-30 21:45:12")
      )

      expect(File.read(file.path)).to eq("2026-08-30 21:45:12 | Telegram Id no autorizado: 123456789\n")
    end
  end
end
