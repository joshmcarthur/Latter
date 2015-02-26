class AuthenticationTokensController < ApplicationController
  before_filter :authenticate_player!

  def show
    current_player.ensure_authentication_token!
  end

  def destroy
    current_player.reset_authentication_token!
    redirect_to player_authentication_token_path(current_player)
  end
end
