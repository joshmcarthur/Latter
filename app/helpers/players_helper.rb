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
        content_tag(:i, '', class: 'icon-chevron-up'),
        :title => I18n.t('trend.improving'),
        :class => 'tooltip trend'
      )
    when :down
      content_tag(
        :a,
        content_tag(:i, '', class: 'icon-chevron-down'),
        :title => I18n.t('trend.worsening'),
        :class => 'tooltip trend'
      )
    else
      ""
    end
  end

  def distance_of_last_game_for(player)
    last_game = player.games.order('updated_at DESC').first

    if last_game
      element = content_tag(
        :span,
        distance_of_time_in_words_to_now(last_game.updated_at),
        :title => last_game.updated_at.strftime("%c")
      )
      I18n.t('player.game_last_played', :distance => element).html_safe
    end
  end

  def link_to_primary_action_for(player)
    if current_player == player
      link_to edit_player_path(player), :class => 'btn btn-large' do
        content_tag(:i, '', :class => 'icon-user') +\
          I18n.t('player.edit.link')
      end
    elsif current_player and !current_player.in_progress_games(player).empty?
      enter_score_options = {
        :remote => true,
        :data => {:disable_with => I18n.t('game.complete.link_loading')},
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
        :data => {:disable_with => I18n.t('game.new.link_loading')},
        :class => 'btn btn-large btn-with-loading challenge'
      }

      link_to games_path(:game => {:challenged_id => player.id}), challenge_link_options do
        content_tag(:i, '', :class => 'icon-screenshot') +\
          I18n.t('game.new.link')
      end
    end
  end

end
