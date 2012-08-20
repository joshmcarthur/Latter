FactoryGirl.define do
  factory :badge do
    sequence(:name) { |n| "Badge #{n}" }
    image_url { "/badges/badge.png" }
    description "Test badge"
  end
end