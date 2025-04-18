require "rails_helper"

RSpec.describe LotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/lotes").to route_to("lotes#index")
    end

    it "routes to #show" do
      expect(get: "/lotes/1").to route_to("lotes#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/lotes").to route_to("lotes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/lotes/1").to route_to("lotes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/lotes/1").to route_to("lotes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/lotes/1").to route_to("lotes#destroy", id: "1")
    end
  end
end
