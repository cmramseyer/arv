require "rails_helper"

RSpec.describe ProductosController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/productos").to route_to("productos#index")
    end

    it "routes to #show" do
      expect(get: "/productos/1").to route_to("productos#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/productos").to route_to("productos#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/productos/1").to route_to("productos#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/productos/1").to route_to("productos#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/productos/1").to route_to("productos#destroy", id: "1")
    end
  end
end
