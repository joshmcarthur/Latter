FactoryGirl.define do
  factory :activity do
    sequence(:message) { |n| "Activity Message #{n}" }
  end
end
