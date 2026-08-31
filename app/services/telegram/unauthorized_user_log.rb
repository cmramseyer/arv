class Telegram::UnauthorizedUserLog
  PATH = Rails.root.join("storage", "telegram_unauthorized_ids.log").freeze

  def self.call(user_id:, path: PATH, now: Time.current)
    timestamp = now.in_time_zone(OrdenFumigacion::LOCALE_TIME_ZONE).strftime("%Y-%m-%d %H:%M:%S")

    File.open(path, "a") do |file|
      file.flock(File::LOCK_EX)
      file.puts("#{timestamp} | Telegram Id no autorizado: #{user_id}")
    end
  end
end
