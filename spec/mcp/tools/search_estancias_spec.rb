require "rails_helper"

RSpec.describe Mcp::Tools::SearchEstancias do
  describe ".call" do
    it "returns matching estancias in name order" do
      create(:estancia, nombre: "San Pedro")
      create(:estancia, nombre: "San Antonio")
      create(:estancia, nombre: "Las Palmas")

      response = described_class.call(query: "SAN", server_context: {})

      expect(response.structured_content).to eq(
        estancias: [
          { id: Estancia.find_by!(nombre: "San Antonio").id, nombre: "San Antonio" },
          { id: Estancia.find_by!(nombre: "San Pedro").id, nombre: "San Pedro" }
        ]
      )
    end

    it "limits the returned estancias" do
      11.times { |index| create(:estancia, nombre: "Estancia #{index}") }

      response = described_class.call(query: "Estancia", limit: 10, server_context: {})

      expect(response.structured_content[:estancias].size).to eq(10)
    end

    it "treats wildcard characters as plain text" do
      create(:estancia, nombre: "Campo 100%")
      create(:estancia, nombre: "Campo Norte")

      response = described_class.call(query: "100%", server_context: {})

      expect(response.structured_content).to eq(
        estancias: [ { id: Estancia.find_by!(nombre: "Campo 100%").id, nombre: "Campo 100%" } ]
      )
    end
  end
end
