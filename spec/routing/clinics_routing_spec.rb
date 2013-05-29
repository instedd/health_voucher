require 'spec_helper'

describe ClinicsController do
  describe "routing" do
    it "routes to #index" do
      get("/sites/1/clinics").should route_to("clinics#index", site_id: '1')
    end

    it "routes to #show" do
      get("/sites/1/clinics/2").should route_to("clinics#show", site_id: '1', id: '2')
    end

    it "should not route new" do
      get("/sites/1/clinics/new").should_not route_to("clinics#new", site_id: '1')
    end

    it "should not route edit" do
      get("/sites/1/clinics/2/edit").should_not be_routable
    end

    it "should not route update" do
      put("/sites/1/clinics/2").should_not be_routable
    end

    it "routes to #create" do
      post("/sites/1/clinics").should route_to("clinics#create", site_id: '1')
    end

    it "routes to #destroy" do
      delete("/sites/1/clinics/2").should route_to("clinics#destroy", site_id: '1', id: '2')
    end
  end
end

