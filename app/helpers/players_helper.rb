module PlayersHelper

  def ranking(player)
    content_tag(:div, :class => 'label label-important ranking') do
      (player.ranking.to_s + "&nbsp;" + trend(player)).html_safe
    end
  end

  def trend(player)
    case player.trend
    when :up
      content_tag(
        :a,
        '',
        :rel => 'tooltip',
        :title => 'Improving in the last 48 hours',
        :class => 'icon-chevron-up trend'
      )
    when :down
      content_tag(
        :a,
        '',
        :rel => 'tooltip',
        :title => 'Worsening in the last 48 hours',
        :class => 'icon-chevron-down trend'
      )
    else
      ""
    end
  end

  def primary_action_button_for(player)
    if current_player == player
      link_to edit_player_path(player), :class => 'btn btn-large' do
        content_tag(:i, '', :class => 'icon-user') +\
          I18n.t('player.edit')
      end
    elsif current_player and !current_player.in_progress_games(player).empty?
      enter_score_options = {
        :remote => true,
        :'data-loading-text' => I18n.t('game.complete.link_loading'),
        :class => 'btn btn-large btn-with-loading'
      }

      link_to new_game_score_path(current_player.in_progress_games(player).first), enter_score_options do
        content_tag(:i, '', :class => 'icon-plus-sign') +\
          I18n.t('game.complete.link')
      end
    elsif current_player
      challenge_link_options = {
        :method => :post,
        :remote => true,
        :'data-loading-text' => I18n.t('game.new.link_loading'),
        :class => 'btn btn-large btn-with-loading challenge'
      }

      link_to games_path(:game => {:challenged_id => player.id}), challenge_link_options do
        content_tag(:i, '', :class => 'icon-screenshot') +\
          I18n.t('game.new.link')
      end
    end
  end
end
