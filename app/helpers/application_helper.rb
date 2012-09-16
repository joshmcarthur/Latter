module ApplicationHelper

  def cache_key_for(object, scope = nil, locale=I18n.locale)
    [Latter::Application.config.version, object, scope, locale].compact
  end

  def player_navigation
    render(:partial => 'layouts/navigation/player_navigation') if current_player
  end

  def anonymous_navigation
    render(:partial => 'layouts/navigation/anonymous_navigation') unless current_player
  end

  def render_alerts
    render(:partial => 'alerts/alert', :collection => Alert.current) if request.url == root_url
  end

end
