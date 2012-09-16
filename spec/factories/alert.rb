FactoryGirl.define do
  factory :alert do
    message { "Alert message" }
    title { "Alert" }
    category { "info" }
    expire_at { DateTime.now + 1.hour }
  end
end
