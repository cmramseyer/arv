class McpController < ActionController::API
  before_action :authenticate_mcp!

  def handle
    status, headers, body = transport.handle_request(request)

    headers.each { |name, value| response.set_header(name, value) }
    self.status = status
    self.response_body = body
  end

  private
    def authenticate_mcp!
      token = request.authorization&.delete_prefix("Bearer ")
      expected_token = ENV.fetch("MCP_ACCESS_TOKEN")

      return if token.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected_token)

      head :unauthorized
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
