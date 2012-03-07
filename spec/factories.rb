FactoryGirl.define do
  factory :player do
    sequence(:name) { |num| "player#{num}" }
    email { |p| "#{p.name}@3months.com" }
  end

  factory :challenge do
    from_player { Factory(:player) }
    to_player { Factory(:player) }
    completed false
  end
end
