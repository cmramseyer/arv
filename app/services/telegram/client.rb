require "json"
require "net/http"

class Telegram::Client
  API_URL = "https://api.telegram.org".freeze

  def initialize(token: ENV.fetch("TELEGRAM_BOT_TOKEN"))
    @token = token
  end

  def send_message(chat_id:, text:)
    post("sendMessage", chat_id: chat_id, text: text)
  end

  private
    def post(method, payload)
      uri = URI("#{API_URL}/bot#{@token}/#{method}")
      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      request.body = payload.to_json
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

      raise "Telegram API request failed with #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end
end
