require "rails_helper"

RSpec.describe DosisController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/dosis").to route_to("dosis#index")
    end

    it "routes to #show" do
      expect(get: "/dosis/1").to route_to("dosis#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/dosis").to route_to("dosis#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/dosis/1").to route_to("dosis#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/dosis/1").to route_to("dosis#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/dosis/1").to route_to("dosis#destroy", id: "1")
    end
  end
end
