FactoryGirl.define do
  factory :award do
    player { FactoryGirl.build(:player) }
    badge { FactoryGirl.build(:badge) }
    award_date { nil }
  end
end