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
    original_creator_id = ENV.fetch("MCP_CREATOR_ID", nil)
    ENV["MCP_ACCESS_TOKEN"] = access_token
    ENV["MCP_CREATOR_ID"] = creator.id.to_s
    example.run
  ensure
    ENV["MCP_ACCESS_TOKEN"] = original_token
    ENV["MCP_CREATOR_ID"] = original_creator_id
  end

  before { host! "localhost" }

  let(:creator) { create(:user) }

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

  it "advertises the available MCP tools" do
    post "/mcp", params: tools_list_request.to_json, headers: headers

    expect(response).to have_http_status(:ok), response.body
    tools = JSON.parse(response.body).dig("result", "tools")

    expect(tools.map { |tool| tool.fetch("name") }).to contain_exactly(
      "search_estancias",
      "search_productos",
      "search_lotes",
      "resolve_order",
      "create_order"
    )
    estancias_tool = tools.find { |tool| tool["name"] == "search_estancias" }
    create_order_tool = tools.find { |tool| tool["name"] == "create_order" }

    expect(estancias_tool.dig("annotations", "readOnlyHint")).to be(true)
    expect(create_order_tool.dig("annotations", "readOnlyHint")).to be(false)
  end

  it "searches estancias through the MCP transport" do
    estancia = create(:estancia, nombre: "Estancia Pepitos")

    post "/mcp", params: tool_call_request(query: "pepito").to_json, headers: headers

    expect(response).to have_http_status(:ok), response.body

    result = JSON.parse(response.body).dig("result", "structuredContent")
    expect(result).to eq("estancias" => [ { "id" => estancia.id, "nombre" => estancia.nombre } ])
  end

  it "creates an order through the MCP transport" do
    estancia = create(:estancia)
    lote = create(:lote, estancia: estancia)
    producto = create(:producto)

    expect do
      post "/mcp",
           params: tool_call_request(
             name: "create_order",
             arguments: {
               request_id: "request-123",
               estancia_id: estancia.id,
               lote_id: lote.id,
               producto_id: producto.id,
               cantidad: 20
             }
           ).to_json,
           headers: headers
    end.to change(OrdenFumigacion, :count).by(1)

    expect(response).to have_http_status(:ok), response.body
    expect(JSON.parse(response.body).dig("result", "structuredContent", "status")).to eq("created")
    expect(OrdenFumigacion.last.creator).to eq(creator)
  end

  private
    def tools_list_request
      {
        jsonrpc: "2.0",
        id: "tools-list",
        method: "tools/list"
      }
    end

    def tool_call_request(name: "search_estancias", arguments: nil, query: nil)
      {
        jsonrpc: "2.0",
        id: "search-estancias",
        method: "tools/call",
        params: {
          name: name,
          arguments: arguments || { query: query }
        }
      }
    end
end
