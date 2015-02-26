module TokenAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_filter :authenticate_player_from_token!
    before_filter :authenticate_player!
  end


  private

  def authenticate_player_from_token!
    auth_token = params[:auth_token].presence
    player       = auth_token && Player.find_by_authentication_token(auth_token.to_s)

    if player
      # Notice we are passing store false, so the player is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in player, store: false
    end
  end

end
