module PlayersHelper

  def ranking(player)
    content_tag(:div, player.ranking, :class => 'label label-important ranking')
  end

  def primary_action_button_for(player)
    if current_player == player
      link_to edit_player_path(player), :class => 'btn btn-large' do
        content_tag(:i, '', :class => 'icon-user') +\
          I18n.t('player.edit')
      end
    elsif current_player and !current_player.in_progress_games(player).empty?
      link_to new_game_score_path(current_player.in_progress_games(player).first), :class => 'btn btn-large' do
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
