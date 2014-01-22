json.cache! game do
  json.id game.id

  json.challenger do
    if game.challenger
      json.partial!("players/player", player: game.challenger)
    else
      json.nil!
    end
  end

  json.challenged do
    if game.challenged
      json.partial!("players/player", player: game.challenged)
    else
      json.nil!
    end
  end

  json.winner_id game.winner_id
  json.score game.score
end