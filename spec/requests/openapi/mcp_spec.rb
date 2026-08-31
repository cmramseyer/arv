require "swagger_helper"

RSpec.describe "MCP API", openapi_spec: "v1/openapi.yaml", type: :request do
  let(:access_token) { "test-mcp-token" }
  let(:creator) { create(:user) }
  let(:Authorization) { nil }
  let(:Accept) { "application/json, text/event-stream" }

  around do |example|
    original_token = ENV.fetch("MCP_ACCESS_TOKEN", nil)
    original_creator_id = ENV.fetch("MCP_CREATOR_ID", nil)
    original_allow_creation = ENV.fetch("ALLOW_CREATION", nil)
    ENV["MCP_ACCESS_TOKEN"] = access_token
    ENV["MCP_CREATOR_ID"] = creator.id.to_s
    ENV.delete("ALLOW_CREATION")
    example.run
  ensure
    ENV["MCP_ACCESS_TOKEN"] = original_token
    ENV["MCP_CREATOR_ID"] = original_creator_id
    ENV["ALLOW_CREATION"] = original_allow_creation
  end

  before { host! "localhost" }

  path "/mcp" do
    post "Handles an MCP JSON-RPC request" do
      tags "MCP"
      consumes "application/json"
      produces "application/json"
      security [ mcpBearerAuth: [] ]

      parameter name: :request,
                in: :body,
                required: true,
                schema: {
                  oneOf: [
                    { "$ref" => "#/components/schemas/McpToolsListRequest" },
                    { "$ref" => "#/components/schemas/McpToolsCallRequest" }
                  ]
                }
      parameter name: :Accept,
                in: :header,
                required: true,
                schema: { type: :string },
                description: "Must include application/json and text/event-stream."

      response "200", "MCP request handled" do
        let(:Authorization) { "Bearer #{access_token}" }
        let(:request) do
          {
            jsonrpc: "2.0",
            id: "tools-list",
            method: "tools/list"
          }
        end

        schema "$ref" => "#/components/schemas/McpJsonRpcResponse"

        run_test!
      end

      response "401", "missing or invalid MCP token" do
        let(:request) do
          {
            jsonrpc: "2.0",
            id: "tools-list",
            method: "tools/list"
          }
        end

        run_test!
      end
    end
  end
end
