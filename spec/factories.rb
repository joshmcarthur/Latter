FactoryGirl.define do
  factory :player do
    sequence(:name) { |num| "player#{num}" }
    email { |p| "#{p.name}@3months.com" }
  end

  factory :challenge do
    association :from_player, :factory => :player
    association :to_player, :factory => :player
    completed false
  end
end
