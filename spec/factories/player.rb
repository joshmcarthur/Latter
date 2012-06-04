FactoryGirl.define do
  factory :player do
    sequence(:name) { |num| "player_#{num}"}
    email { |p| "#{p.name}@3months.com" }
    password "test123"
    password_confirmation "test123"
  end
end
