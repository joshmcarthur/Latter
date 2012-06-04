FactoryGirl.define do
  factory :game do
    challenger { FactoryGirl.build(:player) }
    challenged { FactoryGirl.build(:player) }
    complete false
  end
end
