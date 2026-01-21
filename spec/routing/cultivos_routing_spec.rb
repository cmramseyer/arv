require "rails_helper"

RSpec.describe CultivosController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cultivos").to route_to("cultivos#index")
    end

    it "routes to #show" do
      expect(get: "/cultivos/1").to route_to("cultivos#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/cultivos").to route_to("cultivos#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/cultivos/1").to route_to("cultivos#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cultivos/1").to route_to("cultivos#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cultivos/1").to route_to("cultivos#destroy", id: "1")
    end
  end
end
