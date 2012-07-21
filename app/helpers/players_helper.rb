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
      content_tag(
        :a, 
        '', 
        :rel => 'tooltip',
        :title => 'Unchanged in the last 48 hours',
        :class => 'icon-chevron-left trend a'
      )
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

  def player_class player
    return '' unless current_player
    return 'current' if current_player == player
    return 'challenged' if current_player.in_progress_games(player).present?
    return 'opponent'
  end

  def link_to_primary_action_for(player, content_or_options={}, options={}, &block)
    if block_given?
      options = content_or_options
      content_or_options = capture(&block)
    end

    if current_player
      if current_player == player
        #edit player
        icon_class = 'icon-edit edit'
        icon_label = t 'player.edit'
        path = edit_player_path(player)
      elsif current_player.in_progress_games(player).empty?
        #initiate Challenge
        icon_class = 'icon-screenshot'
        icon_label = t 'game.new.link'
        path = games_path(:game => {:challenged_id => player.id})
        options.merge!(:remote => true, :method => :post)
      else
        #conclude challenge (enter score)
        icon_class = 'icon-screenshot challenged'
        icon_label = t 'player.challenged'
        path = new_game_score_path(current_player.in_progress_games(player).first)
        options.merge!(:remote => true)
      end
      link_to path, options do
        [content_or_options,
         content_tag(:i, '', :class => icon_class),
         content_tag(:span, icon_label)].join.html_safe
      end
    else
      content_tag :span, content_or_options, options.reverse_merge(:class => 'a')
    end
  end
end

#     if current_player == player
#       link_to edit_player_path(player), :class => 'btn btn-large' do
#         content_tag(:i, '', :class => 'icon-user') +\
#           I18n.t('player.edit')
#       end
#     elsif current_player and !current_player.in_progress_games(player).empty?
#       enter_score_options = {
#         :remote => true,
#         :'data-loading-text' => I18n.t('game.complete.link_loading'),
#         :class => 'btn btn-large btn-with-loading'
#       }

#       link_to new_game_score_path(current_player.in_progress_games(player).first), enter_score_options do
#         content_tag(:i, '', :class => 'icon-plus-sign') +\
#           I18n.t('game.complete.link')
#       end
#     elsif current_player
#       challenge_link_options = {
#         :method => :post,
#         :remote => true,
#         :'data-loading-text' => I18n.t('game.new.link_loading'),
#         :class => 'btn btn-large btn-with-loading challenge'
#       }

#       link_to games_path(:game => {:challenged_id => player.id}), challenge_link_options do
#         content_tag(:i, '', :class => 'icon-screenshot') +\
#           I18n.t('game.new.link')
#       end
#     end
#   end
# end
