require "rails_helper"

RSpec.describe "MCP", type: :request do
  let(:access_token) { "test-mcp-token" }
  let(:headers) do
    {
      "Authorization" => "Bearer #{access_token}",
      "Accept" => "application/json, text/event-stream",
      "Content-Type" => "application/json"
    }
  end

  around do |example|
    original_token = ENV.fetch("MCP_ACCESS_TOKEN", nil)
    ENV["MCP_ACCESS_TOKEN"] = access_token
    example.run
  ensure
    ENV["MCP_ACCESS_TOKEN"] = original_token
  end

  before { host! "localhost" }

  it "rejects requests without the MCP bearer token" do
    post "/mcp", params: tools_list_request.to_json, headers: headers.except("Authorization")

    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects requests with an invalid MCP bearer token" do
    post "/mcp",
         params: tools_list_request.to_json,
         headers: headers.merge("Authorization" => "Bearer invalid-token")

    expect(response).to have_http_status(:unauthorized)
  end

  it "advertises only the read-only estancia search tool" do
    post "/mcp", params: tools_list_request.to_json, headers: headers

    expect(response).to have_http_status(:ok), response.body
    expect(JSON.parse(response.body).dig("result", "tools")).to contain_exactly(
      a_hash_including(
        "name" => "search_estancias",
        "annotations" => a_hash_including("readOnlyHint" => true)
      )
    )
  end

  it "searches estancias through the MCP transport" do
    estancia = create(:estancia, nombre: "Estancia Pepitos")

    post "/mcp", params: tool_call_request(query: "pepito").to_json, headers: headers

    expect(response).to have_http_status(:ok), response.body

    result = JSON.parse(response.body).dig("result", "structuredContent")
    expect(result).to eq("estancias" => [ { "id" => estancia.id, "nombre" => estancia.nombre } ])
  end

  private
    def tools_list_request
      {
        jsonrpc: "2.0",
        id: "tools-list",
        method: "tools/list"
      }
    end

    def tool_call_request(query:)
      {
        jsonrpc: "2.0",
        id: "search-estancias",
        method: "tools/call",
        params: {
          name: "search_estancias",
          arguments: { query: query }
        }
      }
    end
end
