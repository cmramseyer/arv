require "rails_helper"

RSpec.describe MaquinistasController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/maquinistas").to route_to("maquinistas#index")
    end

    it "routes to #show" do
      expect(get: "/maquinistas/1").to route_to("maquinistas#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/maquinistas").to route_to("maquinistas#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/maquinistas/1").to route_to("maquinistas#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/maquinistas/1").to route_to("maquinistas#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/maquinistas/1").to route_to("maquinistas#destroy", id: "1")
    end
  end
end
