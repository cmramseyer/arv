require "rails_helper"

RSpec.describe OrdenesFumigacionController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ordenes_fumigacion").to route_to("ordenes_fumigacion#index")
    end

    it "routes to #show" do
      expect(get: "/ordenes_fumigacion/1").to route_to("ordenes_fumigacion#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/ordenes_fumigacion").to route_to("ordenes_fumigacion#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/ordenes_fumigacion/1").to route_to("ordenes_fumigacion#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ordenes_fumigacion/1").to route_to("ordenes_fumigacion#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ordenes_fumigacion/1").to route_to("ordenes_fumigacion#destroy", id: "1")
    end
  end
end
