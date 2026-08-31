class Telegram::AllowedUserIds
  def self.include?(user_id)
    ids.include?(user_id.to_s)
  end

  def self.ids
    ENV.fetch("TELEGRAM_ALLOWED_USER_IDS", "").split(",").map(&:strip).reject(&:blank?)
  end
  private_class_method :ids
end
