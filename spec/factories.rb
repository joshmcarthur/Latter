Factory.sequence(:player_name) do |n|
  "player#{n}"
end

Factory.define(:player) do |player|
  player.name { Factory.next(:player_name) }
  player.email { |u| "#{u.name}@3months.com" }
end

Factory.define(:challenge) do |chal|
  chal.association :from_player, :factory => :player
  chal.association :to_player, :factory => :player
  chal.completed false
end
