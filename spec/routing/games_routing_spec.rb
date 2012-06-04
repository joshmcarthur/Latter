require "spec_helper"

describe GamesController do
  describe "routing" do

    it "routes to #index" do
      get("/games").should route_to("games#index")
    end

    it "routes to #new" do
      get("/games/new").should route_to("games#new")
    end

    it "routes to #show" do
      get("/games/1").should route_to("games#show", :id => "1")
    end

    it "routes to #edit" do
      get("/games/1/edit").should route_to("games#edit", :id => "1")
    end

    it "routes to #create" do
      post("/games").should route_to("games#create")
    end

    it "routes to #update" do
      put("/games/1").should route_to("games#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/games/1").should route_to("games#destroy", :id => "1")
    end

  end
end
