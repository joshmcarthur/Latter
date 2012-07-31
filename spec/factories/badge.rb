FactoryGirl.define do
  factory :badge do
    sequence(:name) { |n| "Badge #{n}" }
    imageURL "/badges/badge.png"
    description "Test badge"
  end
end