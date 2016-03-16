require 'rails_helper'

describe SitesController do
  describe "routing" do
    it "routes to #index" do
      get("/sites").should route_to("sites#index")
    end

    it "routes to #show" do
      get("/sites/1").should route_to("sites#show", id: '1')
    end

    it "routes to #new" do
      get("/sites/new").should route_to("sites#new")
    end

    it "routes to #create" do
      post("/sites").should route_to("sites#create")
    end

    it "routes to #edit" do
      get("/sites/1/edit").should route_to("sites#edit", id: '1')
    end

    it "routes to #update" do
      put("/sites/1").should route_to("sites#update", id: '1')
    end

    it "should not route destroy" do
      delete("/sites/1").should_not be_routable
    end

    it "routes to #assign_cards" do
      get("/sites/1/assign_cards").should route_to("sites#assign_cards", id: '1')
    end

    it "routes to #batch_assign_cards" do
      post("/sites/1/batch_assign_cards").should route_to("sites#batch_assign_cards", id: '1')
    end

    it "routes to #assign_individual_card" do
      post("/sites/1/assign_individual_card").should route_to("sites#assign_individual_card", id: '1')
    end

    it "routes to #return_cards" do
      post("/sites/1/return_cards").should route_to("sites#return_cards", id: '1')
    end

    it "routes to #edit_manager" do
      get("/sites/1/manager").should route_to("sites#edit_manager", id: '1')
    end

    it "routes to #update_manager" do
      put("/sites/1/manager").should route_to("sites#update_manager", id: '1')
    end

    it "routes to #destroy_manager" do
      delete("/sites/1/manager").should route_to("sites#destroy_manager", id: '1')
    end
  end
end

