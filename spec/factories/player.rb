FactoryGirl.define do
  factory :player do
    sequence(:name) { |num| "player_#{num}"}
    email { |p| "#{p.name}@3months.com" }
    confirmed_at Time.now
    changed_password true
  end
end
