Factory.define :player do |p|
  p.sequence(:name) { |num| "player#{num}" }
  p.email { |p| "#{p.name}@3months.com" }
  p.password "test123"
  p.password_confirmation "test123"

  p.after_build { |player_instance| player_instance.valid? }
end

FactoryGirl.define do
  factory :game do
    challenger { Factory(:player) }
    challenged { Factory(:player) }
    complete false
  end

  factory :activity do
    sequence(:message) { |num| "Message #{num}" }
  end
end
