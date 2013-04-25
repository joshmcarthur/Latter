class Sync.Player extends Sync.View

  afterUpdate: ->
    players = $('#players').children('.player')
    players.detach().sort((a, b) ->
      $(b).data().rating - $(a).data().rating
    )
    $('#players').append(players)