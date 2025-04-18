require "rails_helper"

RSpec.describe EstanciasController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/estancias").to route_to("estancias#index")
    end

    it "routes to #show" do
      expect(get: "/estancias/1").to route_to("estancias#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/estancias").to route_to("estancias#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/estancias/1").to route_to("estancias#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/estancias/1").to route_to("estancias#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/estancias/1").to route_to("estancias#destroy", id: "1")
    end
  end
end
