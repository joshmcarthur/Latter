require 'spec_helper'

describe "Players" do
  describe "GET /players" do
    it "works! (now write some real specs)" do
      get players_path
      response.status.should be(200)
    end
  end
end
