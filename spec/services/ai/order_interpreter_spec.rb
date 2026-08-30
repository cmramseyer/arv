require "rails_helper"

RSpec.describe Ai::OrderInterpreter do
  it "limits the agent to read-only MCP tools when creation is disabled" do
    response = double(output_text: "Necesito el producto.")
    responses = double
    client = double(responses: responses)
    interpreter = described_class.new(
      client: client,
      app_url: "https://arv.example",
      mcp_access_token: "mcp-token",
      creation_enabled: false
    )

    expect(responses).to receive(:create) do |params|
      expect(params[:model]).to eq("gpt-4o-mini")
      expect(params[:input]).to include("Aplicar en lote norte")
      expect(params[:tools].first).to include(
        server_url: "https://arv.example/mcp",
        authorization: "mcp-token",
        allowed_tools: %w[
          list_estancias
          search_estancias
          list_productos
          search_productos
          search_lotes
          list_cultivos
          search_cultivos
          resolve_order
        ]
      )
      response
    end

    result = interpreter.call(transcript: "Aplicar en lote norte", request_id: "voice-command-1")

    expect(result).to eq("Necesito el producto.")
  end

  it "allows create_order only when creation is enabled" do
    response = double(output_text: "Orden creada.")
    responses = double
    client = double(responses: responses)
    interpreter = described_class.new(
      client: client,
      app_url: "https://arv.example/",
      mcp_access_token: "mcp-token",
      creation_enabled: true
    )

    expect(responses).to receive(:create) do |params|
      tool = params[:tools].first
      expect(tool[:allowed_tools]).to eq([ "create_order" ])
      expect(params[:input]).to include("request_id voice-command-1")
      response
    end

    result = interpreter.call(transcript: "Crea una orden", request_id: "voice-command-1")

    expect(result).to eq("Orden creada.")
  end
end
