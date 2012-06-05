module PlayersHelper

  def ranking(player)
    content_tag(:div, player.ranking, :class => 'label label-important ranking')
  end

end
