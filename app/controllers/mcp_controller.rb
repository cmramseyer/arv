class McpController < ActionController::API
  before_action :authenticate_mcp!

  def handle
    log_request
    status, headers, body = transport.handle_request(request)
    Rails.logger.info("MCP response status=#{status} method=#{mcp_method} tool=#{mcp_tool_name}")

    headers.each { |name, value| response.set_header(name, value) }
    self.status = status
    self.response_body = body
  rescue StandardError => error
    Rails.logger.error("MCP transport failed: #{error.class}: #{error.message}")
    Rails.logger.error(error.full_message(highlight: false))
    raise
  end

  private
    def authenticate_mcp!
      token = request.authorization&.delete_prefix("Bearer ")
      expected_token = ENV.fetch("MCP_ACCESS_TOKEN")

      return if token.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected_token)

      head :unauthorized
    end

    def log_request
      Rails.logger.info("MCP request method=#{mcp_method} tool=#{mcp_tool_name}")
      return unless mcp_tool_name

      Rails.logger.info("MCP tool arguments=#{params.dig(:params, :arguments).inspect}")
    end

    def mcp_method
      params[:method]
    end

    def mcp_tool_name
      params.dig(:params, :name)
    end

    def transport
      MCP::Server::Transports::StreamableHTTPTransport.new(
        server,
        stateless: true,
        serve_subscriptions_listen: false,
        allowed_hosts: [ app_uri.host ]
      )
    end

    def server
      MCP::Server.new(
        name: "arv",
        version: "1.0.0",
        server_context: { creator: mcp_user },
        tools: mcp_tools
      )
    end

    def mcp_tools
      tools = [
        Mcp::Tools::SearchEstancias,
        Mcp::Tools::ListEstancias,
        Mcp::Tools::SearchProductos,
        Mcp::Tools::ListProductos,
        Mcp::Tools::SearchLotes,
        Mcp::Tools::SearchCultivos,
        Mcp::Tools::ListCultivos,
        Mcp::Tools::ResolveOrder
      ]
      tools << Mcp::Tools::CreateOrder if Mcp::CreationEnabled.call
      tools
    end

    def mcp_user
      User.find(ENV.fetch("MCP_CREATOR_ID", "1"))
    end

    def app_uri
      app_url = ENV.fetch("APP_URL", "http://localhost:3000")
      URI.parse(app_url.include?("://") ? app_url : "https://#{app_url}")
    end
end
