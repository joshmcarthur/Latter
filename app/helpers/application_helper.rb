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
    return if request.url != root_url
    render(:partial => 'alerts/alert', :collection => Alert.current)
  end

  def application_version
    content_tag(:span, t('shared.version', version: Latter::Application.config.version), class: 'label')
  end

  def valid_html_badge
    url = "https://validator.w3.org/check?uri=#{u(request.original_url)}"
    link_to url do
      image_tag(asset_url('html5_badge.svg'), size: '32x32')
    end
  end

  def travis_badge
    if Latter::Application.config.try(:travis_ci_id)
      url = "https://travis-ci.org/#{Latter::Application.config.travis_ci_id}"
      link_to url do
        image_tag url + ".png"
      end
    end
  end
end
