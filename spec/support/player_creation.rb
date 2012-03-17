def all_players
  @players ||= FactoryGirl.create_list(:player, 5)
end
