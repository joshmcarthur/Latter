class ApplicationController < ActionController::Base
  before_filter :needs_password?, :if => :current_player
  before_filter :set_locale
  protect_from_forgery


  # Public: Override default_url_options to automatically mixin the current
  # locale. This ensures that links always have the correct locale set,
  # regardless of whether the actual link_to has it or not.
  def default_url_options(options = {})
    {:locale => I18n.locale}
  end

  private

  # Private: Save the locale that is passed in the URL to the
  # current request.
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # Private - Detect whether the user needs to change their password
  #
  # When players are first created, they are assigned a default password
  # which they must change on first log in.
  # This method checks whether the player has changed their password:
  # - If they have, it carries on
  # - If they have not, it logs them out and redirects them to the change
  #   password page.
  def needs_password?
    if current_player and !current_player.changed_password?
      old_current_player = current_player
      sign_out :player
      old_current_player.send(:generate_reset_password_token!)

      redirect_to edit_player_password_path(:reset_password_token => old_current_player.reset_password_token)
      return false
    else
      return true
    end
  end
end
