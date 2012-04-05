FactoryGirl.define do
  factory :player do
    sequence(:name) { |num| "player#{num}" }
    email { |p| "#{p.name}@3months.com" }
  end

  factory :game do
    challenger { Factory(:player) }
    challenged { Factory(:player) }
    complete false
  end

  factory :activity do
    sequence(:message) { |num| "Message #{num}" }
  end
end
