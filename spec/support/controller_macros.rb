module ControllerMacros
  def login_player
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:player]
      user = FactoryGirl.create(:player)
      sign_in user
    end
  end
end
